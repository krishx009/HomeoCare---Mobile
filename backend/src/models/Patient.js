const mongoose = require('mongoose');

const vitalsSchema = new mongoose.Schema({
  height: Number,
  weight: Number,
  temperature: Number,
  systolicBP: Number,
  diastolicBP: Number,
  heartRate: Number,
}, { _id: false });

const documentSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  url: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    required: true,
  },
  uploadedAt: {
    type: Date,
    default: Date.now,
  },
}, { _id: false });

const patientSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  name: {
    type: String,
    required: [true, 'Patient name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters'],
  },
  dateOfBirth: {
    type: Date,
    required: [true, 'Date of birth is required'],
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: [true, 'Gender is required'],
  },
  contactNumber1: {
    type: String,
    required: [true, 'Contact number is required'],
    trim: true,
  },
  contactNumber2: {
    type: String,
    trim: true,
  },
  email: {
    type: String,
    lowercase: true,
    trim: true,
  },
  address: {
    type: String,
    trim: true,
    maxlength: [500, 'Address cannot exceed 500 characters'],
  },
  medicalHistory: {
    type: String,
    maxlength: [2000, 'Medical history cannot exceed 2000 characters'],
  },
  chiefComplaint: {
    type: String,
    maxlength: [1000, 'Chief complaint cannot exceed 1000 characters'],
  },
  vitals: vitalsSchema,
  documents: [documentSchema],
  totalVisits: {
    type: Number,
    default: 0,
  },
  lastVisitDate: Date,
  nextAppointment: Date,
  tags: [{
    type: String,
    trim: true,
  }],
  notes: {
    type: String,
    maxlength: [2000, 'Notes cannot exceed 2000 characters'],
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Virtual for age calculation
patientSchema.virtual('age').get(function() {
  if (!this.dateOfBirth) return null;
  const today = new Date();
  const birthDate = new Date(this.dateOfBirth);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
});

// Virtual for formatted age
patientSchema.virtual('ageFormatted').get(function() {
  const age = this.age;
  if (age === null) return 'Unknown';
  if (age < 1) {
    const today = new Date();
    const birthDate = new Date(this.dateOfBirth);
    const months = (today.getFullYear() - birthDate.getFullYear()) * 12 +
      (today.getMonth() - birthDate.getMonth());
    return `${months} month${months !== 1 ? 's' : ''}`;
  }
  return `${age} year${age !== 1 ? 's' : ''}`;
});

// Index for search
patientSchema.index({ name: 'text', contactNumber1: 'text', email: 'text' });
patientSchema.index({ doctorId: 1, createdAt: -1 });
patientSchema.index({ doctorId: 1, nextAppointment: 1 });

module.exports = mongoose.model('Patient', patientSchema);
