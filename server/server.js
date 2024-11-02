// Required modules
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
require('dotenv').config();
const cors = require('cors');
const nodemailer = require('nodemailer');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Настройки логов сервера
const logDirectory = path.join(__dirname, process.env.LOG_DIR);
const logFilePath = path.join(logDirectory, process.env.LOG_FILE);

// Убедиться что папка логов сервера существует
if (!fs.existsSync(logDirectory)) {
  fs.mkdirSync(logDirectory);
}

const accessLogStream = fs.createWriteStream(logFilePath, { flags: 'a' });

app.use(morgan('dev'));
app.use(morgan('combined', { stream: accessLogStream }));

app.get('/', (req, res) => {
  res.status(999).send('');
});

function getTransporter(email) {
  const domain = email.split('@')[1];
  let transporter;
  logEvent(`Fetching transporter for domain: ${domain}`);
  logEvent(`Testing with${process.env.GMAIL_USER}`);
  logEvent(`Testing with${process.env.GMAIL_PASS}`);

  switch (domain) {
    case 'gmail.com':
      transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
          user: process.env.GMAIL_USER,
          pass: process.env.GMAIL_PASS,
        },
      });
      break;
    case 'yahoo.com':
      transporter = nodemailer.createTransport({
        service: 'Yahoo',
        auth: {
          user: process.env.YAHOO_USER,
          pass: process.env.YAHOO_PASS,
        },
      });
      break;
    case 'mail.ru':
      transporter = nodemailer.createTransport({
        host: 'smtp.mail.ru',
        port: 465,
        secure: true,
        auth: {
          user: process.env.MAILRU_USER,
          pass: process.env.MAILRU_PASS,
        },
      });
      break;
    // Добавьте остальные службы почты
    default:
      throw new Error('Unsupported email provider');
  }

  return transporter;
}

// Функция кода подтверждения
async function sendOTP(email, otp) {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Код подтверждения',
    text: `Ваш код подтверждения для входа: ${otp}`,
  };

  try {
    const transporter = getTransporter(email);
    await transporter.sendMail(mailOptions);
    console.log(`OTP sent to ${email}`);
    logEvent(`OTP sent to ${email}`);
  } catch (error) {
    console.error(`Failed to send OTP to ${email}:`, error);
    logEvent(`Failed to send OTP to ${email}:`, error);
    throw new Error('Failed to send OTP');
  }
}

// Настройка PostgreSQL подключения
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Генерация надежного токена
function generateToken(user) {
  return jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
    expiresIn: '1h',
  });
}

// Вспомогательная функция написания логов сервера
function logEvent(message) {
  const timestamp = new Date().toISOString();
  fs.appendFileSync(logFilePath, `[${timestamp}] ${message}\n`);
}

function isValidPassword(password) {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;
  // как минимум 8 символов, 1 заглавную букву, 1 строчную букву, 1 цифру и 1 спец. символ
  return passwordRegex.test(password);
}

// Точка регистрации
app.post('/auth/register', async (req, res) => {
  const {
    email,
    password,
    fullName,
    phoneNumber,
    dateOfBirth,
    address,
    securityQuestion,
    securityAnswer
  } = req.body;

  if (!email || !password || !fullName) {
    logEvent('Registration failed: Missing required fields');
    return res.status(400).json({ error: 'Email, password, and full name are required' });
  }

  if (!isValidPassword(password)) {
    logEvent('Registration failed: Password does not meet strength requirements');
    return res.status(400).json({ error: 'Password must be at least 8 characters long and contain a mix of letters, numbers, and special characters.' });
  }

  if (phoneNumber && !isValidPhone(phoneNumber)) {
    logEvent('Registration failed: Invalid phone number format');
    return res.status(400).json({ error: 'Invalid phone number format' });
  }

  if (dateOfBirth && !isValidDate(dateOfBirth)) {
    logEvent('Registration failed: Invalid date format');
    return res.status(400).json({ error: 'Invalid date of birth format' });
  }

  try {
    const userExists = await pool.query(
      'SELECT * FROM users WHERE email = $1 OR (phone_number = $2 AND phone_number IS NOT NULL)',
      [email, phoneNumber]
    );

    if (userExists.rows.length > 0) {
      logEvent(`Registration failed: User with email ${email} or phone ${phoneNumber} already exists`);
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const fields = ['email', 'password', 'full_name'];
    const values = [email, hashedPassword, fullName];
    const placeholders = ['$1', '$2', '$3'];
    let valueCounter = 4;

    if (phoneNumber) {
      fields.push('phone_number');
      values.push(phoneNumber);
      placeholders.push(`$${valueCounter++}`);
    }
    if (dateOfBirth) {
      fields.push('date_of_birth');
      values.push(dateOfBirth);
      placeholders.push(`$${valueCounter++}`);
    }
    if (address) {
      fields.push('address');
      values.push(address);
      placeholders.push(`$${valueCounter++}`);
    }
    if (securityQuestion && securityAnswer) {
      fields.push('security_question', 'security_answer');
      values.push(securityQuestion, securityAnswer);
      placeholders.push(`$${valueCounter++}`, `$${valueCounter++}`);
    }

    const query = `
      INSERT INTO users (${fields.join(', ')}) 
      VALUES (${placeholders.join(', ')}) 
      RETURNING id, email, full_name, phone_number, role, created_at, is_verified
    `;

    const result = await pool.query(query, values);
    const user = result.rows[0];
    const token = generateToken(user);

    logEvent(`New user registered successfully: ${email}`);
    return res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number,
        role: user.role,
        isVerified: user.is_verified,
        createdAt: user.created_at
      }
    });

  } catch (error) {
    console.error(error);
    logEvent(`Error registering user: ${error.message}`);
    return res.status(500).json({ error: 'Error registering user' });
  }
});

function isValidDate(dateString) {
  const date = new Date(dateString);
  return date instanceof Date && !isNaN(date) && date < new Date();
}

function isValidPhone(phone) {
  // Разрешает форматы типа: (123) 456-78-90
  const phoneRegex = /^\([0-9]{3}\)\s[0-9]{3}-[0-9]{4}$/;
  return phoneRegex.test(phone);
}

function obfuscateEmail(email) {
  const [name, domain] = email.split('@');
  const obfuscatedName = name.slice(0, 2) + '*'.repeat(name.length - 4) + name.slice(-2);
  const obfuscatedDomain = domain.slice(0, 1) + '*'.repeat(domain.length - 3) + domain.slice(-2);
  return `${obfuscatedName}@${obfuscatedDomain}`;
}

// Функция для скрытия номера телефона
function obfuscatePhone(phone) {
  return phone.slice(0, 2) + '*'.repeat(phone.length - 4) + phone.slice(-2);
}

// Точка Входа
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    logEvent('Login failed: Missing fields');
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user || !(await bcrypt.compare(password, user.password))) {
      logEvent('Login failed: Invalid credentials');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user);
    logEvent(`User logged in: ${email}`);
    res.status(200).json({ token, user });
  } catch (error) {
    logEvent(`Login error: ${error.message}`);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Проверка существования пользователя по телефону или email
app.post('/auth/check-user', async (req, res) => {
  const { phoneNumber, email } = req.body;

  if (!phoneNumber && !email) {
    logEvent('User existence check failed: Missing phone number or email');
    return res.status(400).json({ error: 'Phone number or email is required' });
  }

  try {
    // Проверка существования пользователя по email или phoneNumber
    const result = await pool.query(
      'SELECT email, phone_number FROM users WHERE email = $1 OR phone_number = $2 LIMIT 1',
      [email, phoneNumber]
    );

    if (result.rows.length > 0) {
      const user = result.rows[0];
      logEvent(`User with email ${email} or phone ${phoneNumber} exists`);
      return res.status(200).json({
        exists: true,
        user: {
          email: user.email ? obfuscateEmail(user.email) : null,
          phoneNumber: user.phone_number ? obfuscatePhone(user.phone_number) : null
        }
      });
    }

    logEvent(`No user found with email ${email} or phone ${phoneNumber}`);
    return res.status(200).json({ exists: false });

  } catch (error) {
    console.error(`Error checking user existence:`, error);
    logEvent(`Error checking user existence: ${error.message}`);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Проверка частичного совпадения email
app.post('/auth/check-partial-email', async (req, res) => {
  const { enteredEmail, obfuscatedEmail } = req.body;

  if (!enteredEmail || !obfuscatedEmail) {
    logEvent('Partial email check failed: Missing enteredEmail or obfuscatedEmail');
    return res.status(400).json({ error: 'Both enteredEmail and obfuscatedEmail are required' });
  }

  try {
    const result = await pool.query(
      'SELECT email FROM users WHERE email LIKE $1 LIMIT 1',
      [`%${enteredEmail}%`]
    );

    if (result.rows.length === 0) {
      logEvent(`Partial email check: No matching email found for enteredEmail ${enteredEmail}`);
      return res.status(404).json({ message: 'No matching email found' });
    }

    const fullEmail = result.rows[0].email;
    const obfuscatedFoundEmail = obfuscateEmail(fullEmail);

    if (obfuscatedFoundEmail === obfuscatedEmail) {
      logEvent(`Partial email check successful for ${enteredEmail}`);
      return res.status(200).json({ message: 'Partial email match successful' });
    } else {
      logEvent(`Partial email check: Obfuscated email does not match for enteredEmail ${enteredEmail}`);
      return res.status(404).json({ message: 'No matching email found' });
    }

  } catch (error) {
    console.error(`Error checking partial email:`, error);
    logEvent(`Error checking partial email: ${error.message}`);
    return res.status(500).json({ error: 'Internal server error' });
  }
});


global.otpStore = {};
const otpAttempts = {};
const OTP_MAX_ATTEMPTS = 3;
const OTP_EXPIRY_MINUTES = 10;

app.post('/auth/verify-code', async (req, res) => {
  const { code, email, exists } = req.body;
  logEvent(`Code verification: ${code}, ${email}, exists: ${exists}`);

  if (!code || !email) {
    logEvent('Code verification failed: Missing code or email');
    return res.status(400).json({ error: 'Code and email are required' });
  }

  // Проверка существует ли код для почты
  if (!global.otpStore[email]) {
    logEvent(`Code verification failed: No OTP found for ${email}`);
    return res.status(400).json({ error: 'No verification code found or code has expired' });
  }

  // Инициализировать попытки если не существует
  if (!otpAttempts[email]) {
    otpAttempts[email] = {
      count: 0,
      timestamp: Date.now(),
    };
  }

  // Проверка просрочен ли код подтверждения (10 минут)
  if (Date.now() - otpAttempts[email].timestamp > OTP_EXPIRY_MINUTES * 60 * 1000) {
    delete global.otpStore[email];
    delete otpAttempts[email];
    logEvent(`Code verification failed: OTP expired for ${email}`);
    return res.status(400).json({ error: 'Verification code has expired' });
  }

  // Проверка превышают ли попытки
  if (otpAttempts[email].count >= OTP_MAX_ATTEMPTS) {
    delete global.otpStore[email];
    delete otpAttempts[email];
    logEvent(`Code verification failed: Max attempts exceeded for ${email}`);
    return res.status(400).json({ error: 'Maximum verification attempts exceeded' });
  }

  // Увеличить попытки
  otpAttempts[email].count++;

  // Проверка правильности кода подтверждения
  if (global.otpStore[email] === code) {
    let fullName = null;

    if (exists) {
      try {
        const result = await pool.query(
          'SELECT full_name FROM users WHERE email LIKE $1 LIMIT 1',
          [`%${email}%`]
        );

        if (result.rows.length === 0) {
          logEvent(`No user found for email: ${email}`);
        } else {
          fullName = result.rows[0].full_name;
          logEvent(`Found user: ${fullName} for email: ${email}`);
        }
      } catch (dbError) {
        logEvent(`Database error: ${dbError}`);
        return res.status(500).json({ error: 'Internal server error' });
      }
    }

    delete global.otpStore[email];
    delete otpAttempts[email];
    logEvent(`Code verified successfully for ${email}`);
    return res.status(200).json({
      message: 'Code verified successfully',
      userData: fullName
    });
  } else {
    const remainingAttempts = OTP_MAX_ATTEMPTS - otpAttempts[email].count;
    logEvent(`Code verification failed for ${email}: Invalid code. ${remainingAttempts} attempts remaining`);
    return res.status(400).json({
      error: 'Invalid verification code',
      remainingAttempts
    });
  }
});

// Отправка кода подтверждения
app.post('/auth/send-verification-code', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    logEvent('Verification code sending failed: Missing email');
    return res.status(400).json({ error: 'Email is required' });
  }

  try {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    if (!global.otpStore) {
      global.otpStore = {};
    }

    // Сохранить код с привязкой ко времени
    global.otpStore[email] = otp;
    otpAttempts[email] = {
      count: 0,
      timestamp: Date.now()
    };

    await sendOTP(email, otp);
    logEvent(`Verification code sent to ${email}`);
    res.status(200).json({ message: 'Verification code sent' });
  } catch (error) {
    // Очистка сохраненных кодов в случае ошибки
    if (global.otpStore && global.otpStore[email]) {
      delete global.otpStore[email];
    }
    if (otpAttempts[email]) {
      delete otpAttempts[email];
    }

    logEvent(`Failed to send verification code: ${error.message}`);
    res.status(500).json({ error: 'Failed to send verification code' });
  }
});


function authenticateToken(req, res, next) {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.sendStatus(401); // Нет токена

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403); // Неверный токен
    req.user = user;
    next();
  });
}

// Точка выхода
app.post('/auth/logout', authenticateToken, async (req, res) => {
  logEvent(`User logged out: ${req.user.email}`); // Use req.user set by authenticateToken
  res.status(200).json({ message: 'Logged out successfully' });
});

// Проверка авторизации
app.get('/auth/verify', authenticateToken, (req, res) => {
  res.status(200).json({ message: 'User is authenticated', user: req.user });
});

// Запустить сервер на порту 5000 если .env не содержит порт
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  logEvent(`Server started on port ${PORT}`);
  console.log(`Server is running on port ${PORT}`);
});
