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

const vitalsSchema = new mongoose.Schema({
  height: Number,
  weight: Number,
  temperature: Number,
  systolicBP: Number,
  diastolicBP: Number,
  heartRate: Number,
}, { _id: false });

const visitSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true,
    index: true,
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  visitDate: {
    type: Date,
    required: [true, 'Visit date is required'],
    default: Date.now,
  },
  chiefComplaint: {
    type: String,
    required: [true, 'Chief complaint is required'],
    maxlength: [1000, 'Chief complaint cannot exceed 1000 characters'],
  },
  symptoms: {
    type: String,
    maxlength: [2000, 'Symptoms cannot exceed 2000 characters'],
  },
  examination: {
    type: String,
    maxlength: [2000, 'Examination notes cannot exceed 2000 characters'],
  },
  diagnosis: {
    type: String,
    maxlength: [1000, 'Diagnosis cannot exceed 1000 characters'],
  },
  medicines: [medicineSchema],
  vitals: vitalsSchema,
  notes: {
    type: String,
    maxlength: [2000, 'Notes cannot exceed 2000 characters'],
  },
  followUpDate: Date,
  attachments: [{
    name: String,
    url: String,
    type: String,
    uploadedAt: {
      type: Date,
      default: Date.now,
    },
  }],
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes
visitSchema.index({ patientId: 1, visitDate: -1 });
visitSchema.index({ doctorId: 1, visitDate: -1 });
visitSchema.index({ followUpDate: 1 });

// Update patient's visit count and last visit date after saving
visitSchema.post('save', async function() {
  try {
    const Patient = mongoose.model('Patient');
    const visitCount = await this.constructor.countDocuments({ patientId: this.patientId });
    await Patient.findByIdAndUpdate(this.patientId, {
      totalVisits: visitCount,
      lastVisitDate: this.visitDate,
      nextAppointment: this.followUpDate,
    });
  } catch (error) {
    console.error('Error updating patient visit info:', error);
  }
});

module.exports = mongoose.model('Visit', visitSchema);
