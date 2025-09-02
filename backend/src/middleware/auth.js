// Simple stub auth middleware.
// In production replace with Google Sign-In verification or OTP.
export const requireUser = (req, res, next) => {
  const userID = req.header("x-user-id");
  if (!userID) return res.status(401).json({ message: "Unauthenticated" });
  req.userID = userID;
  next();
};
