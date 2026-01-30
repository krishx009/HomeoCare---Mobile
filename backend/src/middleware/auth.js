const jwt = require('jsonwebtoken');
const admin = require('../config/firebase');
const User = require('../models/User');

/**
 * Authenticate user using JWT or Firebase token
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.',
      });
    }

    const token = authHeader.split(' ')[1];

    // Try JWT verification first
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'User not found.',
        });
      }

      if (!user.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Account is deactivated.',
        });
      }

      req.user = user;
      req.userId = user._id;
      return next();
    } catch (jwtError) {
      // If JWT fails, try Firebase token
      try {
        const decodedFirebase = await admin.auth().verifyIdToken(token);
        let user = await User.findOne({ firebaseUid: decodedFirebase.uid });
        
        if (!user) {
          // Create user if doesn't exist
          user = await User.create({
            firebaseUid: decodedFirebase.uid,
            email: decodedFirebase.email,
            name: decodedFirebase.name || decodedFirebase.email?.split('@')[0] || 'User',
            photoUrl: decodedFirebase.picture,
          });
        }

        if (!user.isActive) {
          return res.status(401).json({
            success: false,
            message: 'Account is deactivated.',
          });
        }

        req.user = user;
        req.userId = user._id;
        return next();
      } catch (firebaseError) {
        return res.status(401).json({
          success: false,
          message: 'Invalid or expired token.',
        });
      }
    }
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(500).json({
      success: false,
      message: 'Authentication error.',
    });
  }
};

/**
 * Check if user has required role
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Not authenticated.',
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this resource.',
      });
    }

    next();
  };
};

/**
 * Optional authentication - doesn't fail if no token
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      if (user && user.isActive) {
        req.user = user;
        req.userId = user._id;
      }
    } catch (error) {
      // Token invalid, but continue without user
    }

    next();
  } catch (error) {
    next();
  }
};

module.exports = {
  authenticate,
  authorize,
  optionalAuth,
};
