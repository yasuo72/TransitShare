import User from '../models/userModel.js';
import Transaction from '../models/transactionModel.js';

// @desc    Add points to a user
// @route   POST /api/points/add
// @access  Private
const addPoints = async (req, res) => {
  const { userId, points } = req.body;

  const user = await User.findById(userId);

  if (user) {
    user.points += points;
    const updatedUser = await user.save();
    res.json(updatedUser);
  } else {
    res.status(404).json({ message: 'User not found' });
  }
};

// @desc    Tip another user
// @route   POST /api/points/tip
// @access  Private
const tipSharer = async (req, res) => {
  const { toUserId, points } = req.body;
  const fromUserId = req.user._id;

  const fromUser = await User.findById(fromUserId);
  const toUser = await User.findById(toUserId);

  if (fromUser && toUser) {
    if (fromUser.walletBalance >= points) {
      fromUser.walletBalance -= points;
      toUser.walletBalance += points;

      await fromUser.save();
      await toUser.save();

      await Transaction.create({
        fromUserId,
        toUserId,
        points,
      });

      res.json({ message: 'Tip successful' });
    } else {
      res.status(400).json({ message: 'Insufficient balance' });
    }
  } else {
    res.status(404).json({ message: 'User not found' });
  }
};

// @desc    Get points history for a user
// @route   GET /api/points/history/:userId
// @access  Private
const getPointsHistory = async (req, res) => {
  const transactions = await Transaction.find({ toUserId: req.params.userId });
  res.json(transactions);
};
// @desc    Withdraw points from current user (simulate payout)
// @route   POST /api/points/withdraw
// @access  Private
const withdrawPoints = async (req, res) => {
  const { amount } = req.body;

  const numericAmount = Number(amount);

  if (!numericAmount || numericAmount <= 0) {
    res.status(400).json({ message: 'Invalid amount' });
    return;
  }

  const user = await User.findById(req.user._id);

  if (!user) {
    res.status(404).json({ message: 'User not found' });
    return;
  }

  if (user.points < numericAmount) {
    res.status(400).json({ message: 'Not enough points to withdraw' });
    return;
  }

  user.points -= numericAmount;
  await user.save();

  await Transaction.create({
    fromUserId: req.user._id,
    toUserId: req.user._id,
    points: numericAmount,
  });

  res.json({ points: user.points });
};

export { addPoints, tipSharer, getPointsHistory, withdrawPoints };
