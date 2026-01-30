const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Medicine name is required'],
    trim: true,
  },
  potency: {
    type: String,
    required: [true, 'Potency is required'],
    trim: true,
  },
  dosage: {
    type: String,
    required: [true, 'Dosage is required'],
    trim: true,
  },
  duration: {
    type: String,
    trim: true,
  },
  instructions: {
    type: String,
    trim: true,
    maxlength: [500, 'Instructions cannot exceed 500 characters'],
  },
}, { _id: false });

const prescriptionSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true,
    index: true,
  },
  visitId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Visit',
    index: true,
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  prescriptionDate: {
    type: Date,
    required: true,
    default: Date.now,
  },
  diagnosis: {
    type: String,
    maxlength: [1000, 'Diagnosis cannot exceed 1000 characters'],
  },
  medicines: {
    type: [medicineSchema],
    required: [true, 'At least one medicine is required'],
    validate: [arr => arr.length > 0, 'At least one medicine is required'],
  },
  notes: {
    type: String,
    maxlength: [2000, 'Notes cannot exceed 2000 characters'],
  },
  pdfUrl: String,
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes
prescriptionSchema.index({ patientId: 1, prescriptionDate: -1 });
prescriptionSchema.index({ doctorId: 1, prescriptionDate: -1 });

module.exports = mongoose.model('Prescription', prescriptionSchema);
