const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const Prescription = require('../models/Prescription');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Apply authentication to all routes
router.use(authenticate);

/**
 * @route   GET /api/prescriptions
 * @desc    Get all prescriptions for authenticated doctor
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    const {
      patientId,
      visitId,
      startDate,
      endDate,
      sortBy = 'prescriptionDate',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
    } = req.query;

    // Build query
    const queryObj = { doctorId: req.userId };

    if (patientId) {
      queryObj.patientId = patientId;
    }

    if (visitId) {
      queryObj.visitId = visitId;
    }

    // Date range filter
    if (startDate || endDate) {
      queryObj.prescriptionDate = {};
      if (startDate) {
        queryObj.prescriptionDate.$gte = new Date(startDate);
      }
      if (endDate) {
        queryObj.prescriptionDate.$lte = new Date(endDate);
      }
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Sort
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query
    const [prescriptions, total] = await Promise.all([
      Prescription.find(queryObj)
        .populate('patientId', 'name gender dateOfBirth')
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit)),
      Prescription.countDocuments(queryObj),
    ]);

    res.json({
      success: true,
      data: {
        prescriptions,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/prescriptions/:id
 * @desc    Get single prescription
 * @access  Private
 */
router.get('/:id', [
  param('id').isMongoId().withMessage('Invalid prescription ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const prescription = await Prescription.findOne({
      _id: req.params.id,
      doctorId: req.userId,
    }).populate('patientId', 'name gender dateOfBirth contactNumber1');

    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found',
      });
    }

    res.json({
      success: true,
      data: prescription,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/prescriptions
 * @desc    Create a new prescription
 * @access  Private
 */
router.post('/', [
  body('patientId').isMongoId().withMessage('Valid patient ID is required'),
  body('medicines').isArray({ min: 1 }).withMessage('At least one medicine is required'),
  body('medicines.*.name').trim().notEmpty().withMessage('Medicine name is required'),
  body('medicines.*.potency').trim().notEmpty().withMessage('Medicine potency is required'),
  body('medicines.*.dosage').trim().notEmpty().withMessage('Medicine dosage is required'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
        errors: errors.array(),
      });
    }

    const prescriptionData = {
      ...req.body,
      doctorId: req.userId,
      prescriptionDate: req.body.prescriptionDate || new Date(),
    };

    const prescription = await Prescription.create(prescriptionData);
    const populatedPrescription = await Prescription.findById(prescription._id)
      .populate('patientId', 'name gender dateOfBirth');

    res.status(201).json({
      success: true,
      message: 'Prescription created successfully',
      data: populatedPrescription,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/prescriptions/:id
 * @desc    Update a prescription
 * @access  Private
 */
router.put('/:id', [
  param('id').isMongoId().withMessage('Invalid prescription ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    // Remove fields that shouldn't be updated directly
    const { doctorId, patientId, _id, createdAt, ...updateData } = req.body;

    const prescription = await Prescription.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      updateData,
      { new: true, runValidators: true }
    ).populate('patientId', 'name gender dateOfBirth');

    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found',
      });
    }

    res.json({
      success: true,
      message: 'Prescription updated successfully',
      data: prescription,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   DELETE /api/prescriptions/:id
 * @desc    Delete a prescription
 * @access  Private
 */
router.delete('/:id', [
  param('id').isMongoId().withMessage('Invalid prescription ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const prescription = await Prescription.findOneAndDelete({
      _id: req.params.id,
      doctorId: req.userId,
    });

    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found',
      });
    }

    res.json({
      success: true,
      message: 'Prescription deleted successfully',
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
