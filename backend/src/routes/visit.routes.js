const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const Visit = require('../models/Visit');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Apply authentication to all routes
router.use(authenticate);

/**
 * @route   GET /api/visits
 * @desc    Get all visits for authenticated doctor
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    const {
      patientId,
      startDate,
      endDate,
      sortBy = 'visitDate',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
    } = req.query;

    // Build query
    const queryObj = { doctorId: req.userId };

    if (patientId) {
      queryObj.patientId = patientId;
    }

    // Date range filter
    if (startDate || endDate) {
      queryObj.visitDate = {};
      if (startDate) {
        queryObj.visitDate.$gte = new Date(startDate);
      }
      if (endDate) {
        queryObj.visitDate.$lte = new Date(endDate);
      }
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Sort
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query
    const [visits, total] = await Promise.all([
      Visit.find(queryObj)
        .populate('patientId', 'name gender dateOfBirth')
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit)),
      Visit.countDocuments(queryObj),
    ]);

    res.json({
      success: true,
      data: {
        visits,
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
 * @route   GET /api/visits/:id
 * @desc    Get single visit
 * @access  Private
 */
router.get('/:id', [
  param('id').isMongoId().withMessage('Invalid visit ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const visit = await Visit.findOne({
      _id: req.params.id,
      doctorId: req.userId,
    }).populate('patientId', 'name gender dateOfBirth contactNumber1');

    if (!visit) {
      return res.status(404).json({
        success: false,
        message: 'Visit not found',
      });
    }

    res.json({
      success: true,
      data: visit,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/visits
 * @desc    Create a new visit
 * @access  Private
 */
router.post('/', [
  body('patientId').isMongoId().withMessage('Valid patient ID is required'),
  body('chiefComplaint').trim().notEmpty().withMessage('Chief complaint is required'),
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

    const visitData = {
      ...req.body,
      doctorId: req.userId,
      visitDate: req.body.visitDate || new Date(),
    };

    const visit = await Visit.create(visitData);
    const populatedVisit = await Visit.findById(visit._id)
      .populate('patientId', 'name gender dateOfBirth');

    res.status(201).json({
      success: true,
      message: 'Visit created successfully',
      data: populatedVisit,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/visits/:id
 * @desc    Update a visit
 * @access  Private
 */
router.put('/:id', [
  param('id').isMongoId().withMessage('Invalid visit ID'),
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

    const visit = await Visit.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      updateData,
      { new: true, runValidators: true }
    ).populate('patientId', 'name gender dateOfBirth');

    if (!visit) {
      return res.status(404).json({
        success: false,
        message: 'Visit not found',
      });
    }

    res.json({
      success: true,
      message: 'Visit updated successfully',
      data: visit,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   DELETE /api/visits/:id
 * @desc    Delete a visit
 * @access  Private
 */
router.delete('/:id', [
  param('id').isMongoId().withMessage('Invalid visit ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const visit = await Visit.findOneAndDelete({
      _id: req.params.id,
      doctorId: req.userId,
    });

    if (!visit) {
      return res.status(404).json({
        success: false,
        message: 'Visit not found',
      });
    }

    res.json({
      success: true,
      message: 'Visit deleted successfully',
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
