const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const Patient = require('../models/Patient');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Apply authentication to all routes
router.use(authenticate);

/**
 * @route   GET /api/patients
 * @desc    Get all patients for authenticated doctor
 * @access  Private
 */
router.get('/', async (req, res, next) => {
  try {
    const {
      search,
      sortBy = 'createdAt',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
      gender,
      hasAppointment,
    } = req.query;

    // Build query
    const queryObj = { doctorId: req.userId, isActive: true };

    // Search filter
    if (search) {
      queryObj.$or = [
        { name: { $regex: search, $options: 'i' } },
        { contactNumber1: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    // Gender filter
    if (gender) {
      queryObj.gender = gender;
    }

    // Has appointment today filter
    if (hasAppointment === 'today') {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);
      queryObj.nextAppointment = { $gte: today, $lt: tomorrow };
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Sort
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query
    const [patients, total] = await Promise.all([
      Patient.find(queryObj)
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit)),
      Patient.countDocuments(queryObj),
    ]);

    res.json({
      success: true,
      data: {
        patients,
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
 * @route   GET /api/patients/today
 * @desc    Get patients with appointments today
 * @access  Private
 */
router.get('/today', async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const patients = await Patient.find({
      doctorId: req.userId,
      isActive: true,
      nextAppointment: { $gte: today, $lt: tomorrow },
    }).sort({ nextAppointment: 1 });

    res.json({
      success: true,
      data: patients,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/patients/:id
 * @desc    Get single patient
 * @access  Private
 */
router.get('/:id', [
  param('id').isMongoId().withMessage('Invalid patient ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const patient = await Patient.findOne({
      _id: req.params.id,
      doctorId: req.userId,
    });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found',
      });
    }

    res.json({
      success: true,
      data: patient,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/patients
 * @desc    Create a new patient
 * @access  Private
 */
router.post('/', [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('dateOfBirth').isISO8601().withMessage('Valid date of birth is required'),
  body('gender').isIn(['male', 'female', 'other']).withMessage('Valid gender is required'),
  body('contactNumber1').trim().notEmpty().withMessage('Contact number is required'),
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

    const patientData = {
      ...req.body,
      doctorId: req.userId,
    };

    const patient = await Patient.create(patientData);

    res.status(201).json({
      success: true,
      message: 'Patient created successfully',
      data: patient,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/patients/:id
 * @desc    Update a patient
 * @access  Private
 */
router.put('/:id', [
  param('id').isMongoId().withMessage('Invalid patient ID'),
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
    const { doctorId, _id, createdAt, ...updateData } = req.body;

    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      updateData,
      { new: true, runValidators: true }
    );

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found',
      });
    }

    res.json({
      success: true,
      message: 'Patient updated successfully',
      data: patient,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   DELETE /api/patients/:id
 * @desc    Delete a patient (soft delete)
 * @access  Private
 */
router.delete('/:id', [
  param('id').isMongoId().withMessage('Invalid patient ID'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      { isActive: false },
      { new: true }
    );

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found',
      });
    }

    res.json({
      success: true,
      message: 'Patient deleted successfully',
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/patients/:id/documents
 * @desc    Add document to patient
 * @access  Private
 */
router.post('/:id/documents', [
  param('id').isMongoId().withMessage('Invalid patient ID'),
  body('name').trim().notEmpty().withMessage('Document name is required'),
  body('url').isURL().withMessage('Valid document URL is required'),
  body('type').trim().notEmpty().withMessage('Document type is required'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const { name, url, type } = req.body;

    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      {
        $push: {
          documents: { name, url, type, uploadedAt: new Date() },
        },
      },
      { new: true }
    );

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found',
      });
    }

    res.json({
      success: true,
      message: 'Document added successfully',
      data: patient,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   DELETE /api/patients/:id/documents
 * @desc    Remove document from patient
 * @access  Private
 */
router.delete('/:id/documents', [
  param('id').isMongoId().withMessage('Invalid patient ID'),
  body('url').isURL().withMessage('Document URL is required'),
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg,
      });
    }

    const { url } = req.body;

    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, doctorId: req.userId },
      { $pull: { documents: { url } } },
      { new: true }
    );

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found',
      });
    }

    res.json({
      success: true,
      message: 'Document removed successfully',
      data: patient,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
