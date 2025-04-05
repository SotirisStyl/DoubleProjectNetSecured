import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_page.dart';
import 'theme_provider.dart';

class IntroductionPage extends StatelessWidget {
  final String topic;
  final String tableName;
  final String difficulty;

  IntroductionPage({
    super.key,
    required this.topic,
    required this.tableName,
    required this.difficulty,
  });

  final Map<String, List<TextSpan>> introductions = {
    'Privacy, Safety, and Security Issues': [
      TextSpan(
        text: "Introduction to Privacy, Safety, and Security Issues\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text: "The internet has become an essential part of our lives, providing convenience, communication, and information. However, it also presents significant risks related to privacy, safety, and security. Cybercriminals use various methods, such as phishing, malware, and data breaches, to exploit unsuspecting users. Understanding how to identify insecure websites, recognize viruses, and implement best security practices is crucial to maintaining online safety.\n\n",
      ),
      TextSpan(
        text: "Privacy, Safety, and Security Issues\n\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text: "Personal Data Protection\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Personal data includes information such as names, addresses, phone numbers, social security numbers, and financial details. Hackers and cybercriminals seek to steal this data for identity theft, fraud, or unauthorized access to accounts. To protect personal information:\n",
      ),
      TextSpan(text: "• Avoid sharing sensitive details on public platforms.\n"),
      TextSpan(text: "• Use strong, unique passwords for different accounts.\n"),
      TextSpan(text: "• Enable Two-Factor Authentication (2FA) for additional security.\n"),
      TextSpan(text: "• Regularly review and update privacy settings on websites and social media.\n\n"),

      TextSpan(
        text: "Phishing and Social Engineering Attacks\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Phishing is a tactic where cybercriminals impersonate legitimate organizations to steal sensitive information. This can be done through:\n",
      ),
      TextSpan(text: "• Emails claiming to be from banks, social media sites, or trusted businesses.\n"),
      TextSpan(text: "• Fake login pages that capture usernames and passwords.\n"),
      TextSpan(text: "• Messages urging users to click on malicious links or download attachments.\n"),
      TextSpan(text: "To avoid phishing attacks:\n"),
      TextSpan(text: "• Verify email senders before clicking on links.\n"),
      TextSpan(text: "• Check website URLs for authenticity.\n"),
      TextSpan(text: "• Avoid responding to unexpected messages requesting personal data.\n\n"),

      TextSpan(
        text: "Public Wi-Fi Risks\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Using public Wi-Fi in cafes, airports, or hotels can expose users to security risks such as Man-in-the-Middle (MITM) attacks. Hackers can intercept data transmitted over unsecured networks, gaining access to passwords and personal information. To stay safe:\n",
      ),
      TextSpan(text: "• Use a Virtual Private Network (VPN) when connecting to public Wi-Fi.\n"),
      TextSpan(text: "• Avoid accessing sensitive accounts or making financial transactions on public networks.\n"),
      TextSpan(text: "• Turn off automatic Wi-Fi connections on mobile devices.\n\n"),

      TextSpan(
        text: "Identifying Insecure Websites\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Insecure websites pose a risk to users by exposing them to data theft, malware infections, or fraud. Recognizing the signs of an insecure website is key to browsing safely.\n\n",
      ),
      TextSpan(
        text: "Checking for HTTPS\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "A secure website uses HTTPS (Hypertext Transfer Protocol Secure) instead of HTTP. HTTPS encrypts the data exchanged between users and websites, reducing the risk of cyberattacks. Signs of a secure website:\n",
      ),
      TextSpan(text: "• A padlock icon in the address bar.\n"),
      TextSpan(text: "• The URL starts with \"https://\" instead of \"http://\".\n"),
      TextSpan(text: "• A valid SSL (Secure Sockets Layer) certificate.\n\n"),

      TextSpan(
        text: "Suspicious Website Behaviour\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Some websites are designed to trick users into providing personal data or downloading malware. Warning signs include:\n",
      ),
      TextSpan(text: "• Excessive pop-ups and ads prompting downloads.\n"),
      TextSpan(text: "• Spelling errors and poor website design.\n"),
      TextSpan(text: "• Requests for unnecessary personal information.\n"),
      TextSpan(text: "• Unverified or missing contact information.\n\n"),

      TextSpan(
        text: "Fake or Malicious Links\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Cybercriminals create fake websites that mimic legitimate ones to steal user credentials. To spot fake links:\n",
      ),
      TextSpan(text: "• Hover over the link before clicking to check the actual URL.\n"),
      TextSpan(text: "• Be cautious of shortened URLs (e.g., bit.ly links) without context.\n"),
      TextSpan(text: "• Avoid websites that offer deals too good to be true.\n\n"),

      TextSpan(
        text: "Understanding Viruses and Malware\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Viruses and malware are malicious software programs designed to damage or gain unauthorized access to devices. Recognizing and preventing malware infections is essential for cybersecurity.\n\n",
      ),
      TextSpan(
        text: "Common Types of Malware\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: "• Viruses: Programs that attach themselves to legitimate files and spread when opened.\n"),
      TextSpan(text: "• Trojans: Malware disguised as legitimate software that allows hackers to access systems.\n"),
      TextSpan(text: "• Ransomware: Locks or encrypts files and demands payment for access.\n"),
      TextSpan(text: "• Spyware: Secretly collects user information, such as keystrokes and browsing history.\n"),
      TextSpan(text: "• Worms: Self-replicating malware that spreads across networks without user interaction.\n\n"),

      TextSpan(
        text: "Signs of a Malware Infection\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: "• Slow device performance or crashes.\n"),
      TextSpan(text: "• Unexpected pop-ups and ads.\n"),
      TextSpan(text: "• Programs opening or closing automatically.\n"),
      TextSpan(text: "• Unauthorized access to personal accounts.\n\n"),

      TextSpan(
        text: "How to Protect Against Malware\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: "• Install reputable antivirus and anti-malware software.\n"),
      TextSpan(text: "• Keep operating systems and applications updated.\n"),
      TextSpan(text: "• Avoid downloading software from untrusted sources.\n"),
      TextSpan(text: "• Do not open email attachments from unknown senders.\n\n"),

      TextSpan(
        text: "Best Practices for Online Security\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: "• Use Strong, Unique Passwords: Avoid using easily guessable passwords. Consider using a password manager.\n"),
      TextSpan(text: "• Enable Multi-Factor Authentication (MFA): Adds an extra layer of security beyond passwords.\n"),
      TextSpan(text: "• Keep Software Updated: Patching vulnerabilities reduces exposure to cyber threats.\n"),
      TextSpan(text: "• Backup Important Data: Regular backups protect against ransomware attacks.\n"),
      TextSpan(text: "• Be Cautious with Email Attachments and Links: Always verify before opening unknown files or clicking links.\n\n"),

      TextSpan(
        text: "Conclusion\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "Understanding privacy, safety, and security risks on the internet is essential for protecting personal information and preventing cyber threats. By identifying insecure websites, recognizing phishing attempts, and preventing malware infections, users can maintain a secure online experience. Following best practices such as using strong passwords, enabling security features, and being cautious online can significantly reduce risks and enhance cybersecurity.\n",
      ),
  ],
    'Cyber Hygiene': [
      TextSpan(
        text: "Introduction to Cyber Hygiene\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        "In the digital age, cyber hygiene is as crucial as personal hygiene. Just as you maintain cleanliness to prevent illness, cyber hygiene involves adopting habits that keep your online presence secure. One of the most fundamental aspects of cyber hygiene is creating and managing strong passwords. Weak or reused passwords are among the most common ways cybercriminals gain unauthorized access to accounts and sensitive information. This guide will help you understand the importance of strong passwords, how to create them, and best practices for managing them.\n\n",
      ),
      TextSpan(
        text: "🔑 Why Are Strong Passwords Important?\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        "Passwords act as the first line of defence against cyber threats. A weak password can be easily guessed or cracked using methods like brute force attacks, where hackers try numerous combinations until they find the right one. Using strong, unique passwords for each account minimizes the risk of unauthorized access, especially if one account becomes compromised.\n\n",
      ),
      TextSpan(
        text: "🛡️ What Makes a Password Strong?\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(text: "A strong password is one that is difficult for others (and computers) to guess or crack. Key characteristics include:\n"),
      TextSpan(text: "• Length: At least 12 characters long. Longer passwords are generally more secure.\n"),
      TextSpan(text: "• Complexity: A mix of uppercase letters (A-Z), lowercase letters (a-z), numbers (0-9), and special symbols (!, @, #, %, etc.).\n"),
      TextSpan(text: "• Unpredictability: Avoid common words, predictable patterns (like \"123456\" or \"password\"), and personal information (such as names, birthdays, or pet names).\n"),
      TextSpan(text: "• Passphrases: Using a combination of random words or a sentence (e.g., \"Purple!Sky_42RunningDog\") makes passwords both strong and memorable.\n\n"),

      TextSpan(
        text: "🚫 Common Password Mistakes to Avoid\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(text: "• Using easily guessable information: Names, birthdays, or common words.\n"),
      TextSpan(text: "• Reusing passwords across multiple accounts: If one account is breached, others become vulnerable.\n"),
      TextSpan(text: "• Short passwords: They are easier to crack through automated tools.\n"),
      TextSpan(text: "• Storing passwords in unsafe places: Writing them on sticky notes or saving them in plain text files.\n\n"),

      TextSpan(
        text: "🗂️ Managing Your Passwords Effectively\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(text: "Keeping track of strong, unique passwords for every account can be challenging. Consider these solutions:\n"),
      TextSpan(text: "• Password Managers: These tools store and organize your passwords securely, allowing you to use complex passwords without having to remember them all.\n"),
      TextSpan(text: "• Two-Factor Authentication (2FA): Adds an extra layer of security by requiring a second form of verification, like a code sent to your phone.\n"),
      TextSpan(text: "• Regular Password Updates: Changing passwords periodically reduces the risk of long-term exposure if a breach occurs.\n"),
      TextSpan(text: "• Monitor for Breaches: Use services like \"Have I Been Pwned\" to check if your credentials have been compromised.\n\n"),

      TextSpan(
        text: "🔍 How Attackers Crack Passwords\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(text: "Cybercriminals use various techniques to gain access to accounts:\n"),
      TextSpan(text: "• Brute Force Attacks: Trying every possible combination until the password is found.\n"),
      TextSpan(text: "• Phishing: Tricking users into revealing their passwords through fake emails or websites.\n"),
      TextSpan(text: "• Dictionary Attacks: Using common words and variations to guess passwords.\n"),
      TextSpan(text: "• Credential Stuffing: Using leaked passwords from other breaches to access different accounts.\n"),
      TextSpan(text: "• Exploiting Security Questions: Hackers may guess answers to common security questions, especially if the information is public.\n\n"),

      TextSpan(
        text: "💡 Tips for Creating Strong Passwords\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(text: "✅ Use at least 12 characters.\n"),
      TextSpan(text: "✅ Include a mix of letters, numbers, and symbols.\n"),
      TextSpan(text: "✅ Avoid using personal information.\n"),
      TextSpan(text: "✅ Create memorable passphrases using random words.\n"),
      TextSpan(text: "✅ Use a password manager to handle complex passwords.\n"),
      TextSpan(text: "✅ Enable two-factor authentication wherever possible.\n"),
      TextSpan(text: "✅ Change passwords immediately after a known breach.\n"),
      TextSpan(text: "✅ Avoid reusing passwords across different accounts.\n\n"),

      TextSpan(
        text: "🏆 Conclusion\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        "Strong password creation is a vital component of good cyber hygiene. By understanding how attackers operate and following best practices, you can significantly reduce the risk of cyber threats. Remember, your passwords are the keys to your digital life—keep them strong, unique, and secure.\n\n",
      ),
      TextSpan(
        text: "Stay vigilant. Stay secure. 🛡️",
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ],
    'Safe Internet Usage': [
      const TextSpan(
        text:"Introduction to Safe Internet Usage\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const TextSpan(
        text:
        "In today’s digital world, using the Internet safely is essential for protecting personal information, securing devices, and ensuring a positive online experience. This guide will cover key topics to help you understand how to navigate the Internet securely, recognise threats, and practice good online habits.\n\n",
      ),
      const TextSpan(
        text: "1. Creating and Managing Strong Passwords\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Passwords are your first line of defence online. A strong password should be at least 12 characters long, combining uppercase and lowercase letters, numbers, and symbols (e.g., 7gLp@92!rQ). Avoid using easily guessed information like birthdays or common words. Using a password manager is recommended to store and generate strong, unique passwords for different accounts. Reusing passwords increases the risk of multiple accounts being compromised if one is breached.\n\n",
      ),
      const TextSpan(
        text: "2. Recognizing Secure Websites and Connections\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "When browsing, always check for a padlock icon in the address bar and ensure the URL starts with 'https://'. The 's' stands for secure, meaning data sent between your browser and the website is encrypted. Avoid entering personal information on sites that only use 'http://' as they are not secure.\n\n",
      ),
      const TextSpan(
        text: "3. Safe Browsing Habits\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   - Avoid clicking on suspicious links: Emails or pop-ups claiming you’ve won a prize are common phishing attempts. Always verify the sender and avoid clicking on unexpected links.\n"
            "   - Be cautious with downloads: Only download files from trusted websites to prevent malware infections.\n"
            "   - Use pop-up blockers:These help prevent malicious pop-ups that can contain harmful links or scams.\n\n",
      ),
      const TextSpan(
        text: "4. Protecting Personal Information\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Never share sensitive information like your home address, bank details, or passwords on public platforms. Be cautious about what you post online, including personal details that can be used to guess security questions (e.g., pet names or birthdates).\n\n",
      ),
      const TextSpan(
        text: "5. Public Wi-Fi and VPN Usage\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Public Wi-Fi networks are convenient but often insecure. Avoid conducting sensitive activities like online banking on public Wi-Fi unless using a VPN (Virtual Private Network), which encrypts your connection, keeping your data secure from potential eavesdroppers.\n\n",
      ),
      const TextSpan(
        text: "6. Two-Factor Authentication (2FA) and Advanced Security\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Enabling two-factor authentication adds an extra layer of security by requiring a second form of verification, like a text code or a hardware key, along with your password. Hardware security keys are considered the most secure form of 2FA.\n\n",
      ),
      const TextSpan(
        text: "7. Recognizing and Avoiding Phishing Attempts\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Phishing scams trick users into providing sensitive information by impersonating trusted sources. Warning signs include:\n"
              "•	Urgent requests for information.\n"
              "•	Emails with suspicious links or unexpected attachments.\n"
              "•	Offers that seem too good to be true.\n"
              "If you receive a suspicious email, do not click on links or open attachments. Report it to your email provider or IT department.\n\n",
      ),
      const TextSpan(
        text:"8. Software Updates and Antivirus Protection\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Regularly update software and operating systems to fix security vulnerabilities. Use reputable antivirus software and keep it updated to protect against malware, spyware, and ransomware.\n\n",
      ),
      const TextSpan(
        text: "9. Understanding Cyber Threats\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Common threats include:\n"
              "•	Phishing: Fraudulent attempts to gain sensitive information.\n"
              "•	Malware: Malicious software that can damage devices.\n"
              "•	Ransomware: Malware that locks your files until a ransom is paid.\n"
              "•	DDoS (Distributed Denial-of-Service) Attacks: Attempts to overwhelm a network, making it unavailable.\n\n",
      ),
      const TextSpan(
        text: "10. Privacy Settings and Online Behaviour\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "Regularly review privacy settings on social media and devices. Limit location sharing and be cautious of accepting friend requests from unknown individuals. Use privacy-focused browsers and consider disabling cookies for enhanced privacy.\n\n",
      ),
      const TextSpan(
        text: "11. Physical and Device Security\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "•	Log out of accounts on shared or public computers.\n"
              "•	Avoid using public USB charging stations as they may carry malware.\n"
              "•	Avoid using public USB charging stations as they may carry malware.\n\n",
      ),
      const TextSpan(
        text: "By following these guidelines, you can browse the internet more safely, protect your personal information, and avoid common online threats. Safe internet usage isn’t just about technology—it’s about being aware, cautious, and proactive.\n"
      )
    ],
    'Social Cyber Attacks': [
        const TextSpan(
          text:"Introduction to Social Cyber Attacks\n",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextSpan(
        text:
        "As digital communication becomes more integrated into everyday life, cyber threats and social cyber-attacks have become increasingly prevalent. Cyberbullying, cyberstalking, and other forms of online harassment are major concerns that affect individuals worldwide. Additionally, the ability to identify insecure websites and protect against viruses is crucial to maintaining online security and privacy.\n\nThis document provides an overview of these threats, their impact, and best practices for staying safe online.\n\n",
        ),
        TextSpan(
        text: "Understanding Social Cyber Attacks\n",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        // Cyberbullying
        TextSpan(text: "\n1. Cyberbullying\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "Cyberbullying refers to the use of digital platforms to harass, intimidate, or harm others. This can take many forms, including:\n"),
        TextSpan(text: "• Sending mean or threatening messages\n"),
        TextSpan(text: "• Posting embarrassing photos or videos without consent\n"),
        TextSpan(text: "• Spreading false rumors online\n"),
        TextSpan(text: "• Excluding individuals from online groups or conversations\n"),
        TextSpan(text: "• Impersonating someone to cause harm or embarrassment\n"),

        TextSpan(text: "\nEffects of Cyberbullying:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Emotional distress, anxiety, or depression\n"),
        TextSpan(text: "• Loss of self-esteem and confidence\n"),
        TextSpan(text: "• Social withdrawal and academic difficulties\n"),
        TextSpan(text: "• In extreme cases, cyberbullying can lead to self-harm or suicide\n"),

        TextSpan(text: "\nHow to Prevent Cyberbullying:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Think before you post or comment\n"),
        TextSpan(text: "• Avoid engaging with cyberbullies and do not retaliate\n"),
        TextSpan(text: "• Use privacy settings to limit interactions\n"),
        TextSpan(text: "• Report and block abusive users on social media platforms\n"),
        TextSpan(text: "• Talk to a trusted person if experiencing cyberbullying\n"),

        // Cyberstalking
        TextSpan(text: "\n2. Cyberstalking\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "Cyberstalking involves repeated and unwanted online attention that instils fear or distress in the victim. Cyberstalkers may:\n"),
        TextSpan(text: "• Monitor someone’s online activities excessively\n"),
        TextSpan(text: "• Send threatening messages or emails\n"),
        TextSpan(text: "• Track personal locations through social media check-ins\n"),
        TextSpan(text: "• Spread false or harmful information about someone\n"),
        TextSpan(text: "• Use spyware or hacking methods to access personal information\n"),

        TextSpan(text: "\nPreventive Measures:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Do not share personal details such as addresses or daily routines online\n"),
        TextSpan(text: "• Use strong, unique passwords for all accounts\n"),
        TextSpan(text: "• Regularly update privacy settings on social media\n"),
        TextSpan(text: "• Report and block individuals engaging in cyberstalking\n"),
        TextSpan(text: "• If cyberstalking escalates, seek legal action or police intervention\n"),

        // Catfishing
        TextSpan(text: "\n3. Online Impersonation and Catfishing\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "Catfishing refers to creating a fake identity online to deceive others, often for financial fraud, emotional manipulation, or cyber harassment. Victims may be tricked into sharing personal information, sending money, or forming relationships based on false identities.\n"),

        TextSpan(text: "\nHow to Spot a Catfish:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Suspiciously perfect or inconsistent online profiles\n"),
        TextSpan(text: "• Reluctance to video call or meet in person\n"),
        TextSpan(text: "• Requests for financial assistance or personal details\n"),
        TextSpan(text: "• Use of stock photos instead of real pictures\n"),

        TextSpan(text: "\nHow to Protect Yourself:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Verify identities before forming online relationships\n"),
        TextSpan(text: "• Avoid sharing sensitive personal or financial information\n"),
        TextSpan(text: "• Conduct a reverse image search on profile pictures\n"),

        // Identifying Insecure Websites
        TextSpan(text: "Identifying Insecure Websites\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: "Insecure websites pose a serious risk to users, potentially exposing them to hacking, identity theft, and malware infections. Here are ways to determine if a website is safe:\n"),

        TextSpan(text: "\n1. HTTPS vs. HTTP\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• A secure website will use HTTPS (Hypertext Transfer Protocol Secure), which encrypts data and protects users from cyber threats.\n"),
        TextSpan(text: "• Signs of an insecure website:\n"),
        TextSpan(text: "  o URL begins with \"http://\" instead of \"https://\"\n"),
        TextSpan(text: "  o No padlock icon next to the URL\n"),
        TextSpan(text: "  o Browser warnings about security risks\n"),

        TextSpan(text: "\n2. Signs of a Fake or Malicious Website\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Excessive pop-ups and redirects\n"),
        TextSpan(text: "• Poor grammar and spelling mistakes\n"),
        TextSpan(text: "• Unsecured payment methods\n"),
        TextSpan(text: "• Offers that seem “too good to be true”\n"),

        TextSpan(text: "\nHow to Stay Safe:\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Only enter personal or payment information on secure websites\n"),
        TextSpan(text: "• Check for legitimate contact information and business credentials\n"),
        TextSpan(text: "• Use trusted cybersecurity tools to flag unsafe sites\n"),

        // Viruses and Malware
        TextSpan(text: "Understanding Viruses and Malware\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: "Viruses and malware are malicious software programs designed to harm computers, steal information, or gain unauthorized access to systems. Some common types include:\n"),

        TextSpan(text: "\n1. Types of Malware\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Viruses – Attach to legitimate files and spread when executed\n"),
        TextSpan(text: "• Trojans – Disguised as legitimate software but allow hackers to access your system\n"),
        TextSpan(text: "• Ransomware – Encrypts files and demands a ransom for their release\n"),
        TextSpan(text: "• Spyware – Secretly collects personal information and online activities\n"),
        TextSpan(text: "• Worms – Spread without user interaction, exploiting security flaws\n"),

        TextSpan(text: "\n2. How to Detect a Virus or Malware Infection\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Slow computer performance\n"),
        TextSpan(text: "• Frequent crashes or unexpected shutdowns\n"),
        TextSpan(text: "• Unusual pop-ups and unwanted advertisements\n"),
        TextSpan(text: "• Unauthorized changes to files or settings\n"),
        TextSpan(text: "• Unfamiliar programs running in the background\n"),

        TextSpan(text: "\n3. How to Protect Against Viruses and Malware\n", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: "• Install and regularly update antivirus software\n"),
        TextSpan(text: "• Avoid downloading files from unknown or untrusted sources\n"),
        TextSpan(text: "• Keep operating systems and applications up to date\n"),
        TextSpan(text: "• Do not click on suspicious links or email attachments\n"),
        TextSpan(text: "• Regularly back up important data to an external device or cloud storage\n"),

        // Best Practices
        TextSpan(text: "Best Practices for Staying Safe Online\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: "1. Use Strong, Unique Passwords – Avoid common passwords and consider using a password manager.\n"),
        TextSpan(text: "2. Enable Multi-Factor Authentication (MFA) – Adds an extra layer of security beyond just passwords.\n"),
        TextSpan(text: "3. Monitor Your Digital Footprint – Be mindful of what you share online and regularly review your privacy settings.\n"),
        TextSpan(text: "4. Be Cautious with Email and Messages – Do not click on unknown links or attachments.\n"),
        TextSpan(text: "5. Report Cyber Threats – If you experience cyberbullying, stalking, or malware attacks, report them to the appropriate platforms or authorities.\n"),

        // Conclusion
        TextSpan(text: "\nConclusion\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: "Social cyber-attacks, including cyberbullying, cyberstalking, and impersonation, have real-world consequences and can cause significant emotional and psychological harm. Additionally, identifying insecure websites and understanding how viruses work are essential skills for staying safe online. By implementing security best practices, reporting online abuse, and staying informed, users can significantly reduce their risk of falling victim to cyber threats.\n"),
    ],
    'Basic Email Security': [
      TextSpan(
        text: 'Introduction to Basic Email Security:\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'Recognizing Phishing Emails, Identifying Insecure Websites, and Understanding Viruses\n\n',
      ),
      TextSpan(
        text: '📧 Why Email Security Matters\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Email is a vital communication tool for both personal and professional use, making it a common target for cybercriminals. Threats like phishing emails, insecure websites, and computer viruses can lead to data breaches, financial loss, and identity theft. Understanding how to identify and avoid these threats is crucial for staying safe online.\n\n',
      ),
      TextSpan(
        text: '🕵️‍♂️ Recognizing Phishing Emails\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Phishing is a cyber-attack where attackers try to trick you into providing sensitive information like passwords, credit card numbers, or personal details. These fraudulent emails often appear to come from trusted sources, such as banks, online services, or even friends.\n',
      ),
      TextSpan(
        text: '🔎 Common Signs of a Phishing Email:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '• Urgency and Threats\n'),
      TextSpan(text: '• Suspicious Links\n'),
      TextSpan(text: '• Unexpected Attachments\n'),
      TextSpan(text: '• Spelling and Grammar Errors\n'),
      TextSpan(text: '• Generic Greetings\n'),
      TextSpan(text: '• Unusual Sender Address\n'),
      TextSpan(
        text:
        '✅ Tip: Always hover over links to preview the URL before clicking. Never provide sensitive information through email unless you are absolutely sure of the sender’s authenticity.\n\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(
        text: '🌐 Identifying Insecure Websites\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Accessing websites through email links can be risky if the site isn’t secure.\n',
      ),
      TextSpan(
        text: '🔐 How to Identify Secure Websites:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '• Look for "https://"\n'),
      TextSpan(text: '• Padlock Icon\n'),
      TextSpan(text: '• Beware of Lookalike URLs\n'),
      TextSpan(
        text:
        '⚠️ Avoid: Clicking on links that lead to sites with warnings from your browser or those that look suspicious.\n\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(
        text: '🦠 Understanding Viruses and Malware in Emails\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Viruses and malware can be delivered through email attachments, links, or even through images.\n',
      ),
      TextSpan(
        text: '🔔 How Viruses Spread via Email:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '• Malicious Attachments\n'),
      TextSpan(text: '• Embedded Links\n'),
      TextSpan(text: '• Infected Images/Videos\n'),
      TextSpan(
        text: '🔑 Prevention Tips:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '• Only open attachments from trusted senders\n'),
      TextSpan(text: '• Use antivirus software to scan attachments\n'),
      TextSpan(text: '• Regularly update your device\n'),
      TextSpan(text: '• Do not download unexpected files\n\n'),
      TextSpan(
        text: '🛡️ Best Practices for Email Security\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '✅ Verify Sender Identity\n'),
      TextSpan(text: '✅ Avoid Clicking on Suspicious Links\n'),
      TextSpan(text: '✅ Enable Two-Factor Authentication (2FA)\n'),
      TextSpan(text: '✅ Use Spam Filters\n'),
      TextSpan(text: '✅ Report Phishing Attempts\n'),
      TextSpan(text: '✅ Regularly Update Software\n'),
      TextSpan(text: '✅ Monitor Your Accounts\n\n'),
      TextSpan(
        text: '🚀 Conclusion\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Being aware of how phishing emails, insecure websites, and viruses work is the first step to protecting yourself online. Stay cautious with email communications, always verify links and attachments, and keep your devices secure. Good email security habits can save you from potential scams and cyber threats.\n\nStay vigilant, stay secure! 🛡️',
      ),
    ],
    'Social Media Security': [
      TextSpan(
        text: 'Social Media Security Guide\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'Social media platforms have become an integral part of our daily lives, allowing us to connect, share, and engage with people worldwide. However, while these networks offer numerous benefits, they also pose significant security risks. Cybercriminals, hackers, and scammers are constantly looking for ways to exploit users through phishing attempts, social engineering, and identity theft. Understanding social media security is crucial to protecting your personal information and online identity.\n\n',
      ),

      // Passwords & 2FA
      TextSpan(
        text: 'Creating Strong Passwords and Enabling Two-Factor Authentication (2FA)\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'One of the most fundamental steps in securing your social media accounts is creating a strong, unique password. A good password should be a combination of uppercase and lowercase letters, numbers, and special characters. Avoid using easily guessable information like birthdays or common words. Additionally, enabling Two-Factor Authentication (2FA) adds an extra layer of security by requiring a second form of verification, such as a text message code or authentication app.\n\n',
      ),

      // Phishing
      TextSpan(
        text: 'Recognizing and Avoiding Phishing Attempts\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Phishing is a common cyber threat where attackers impersonate trusted sources to trick users into providing personal information or login credentials. To stay safe:\n',
      ),
      TextSpan(text: '• Never click on suspicious links, especially from unknown senders.\n'),
      TextSpan(text: '• Always verify the sender before responding to messages that request personal details.\n'),
      TextSpan(text: '• Use official websites instead of logging in through email links.\n\n'),

      // Public Wi-Fi
      TextSpan(
        text: 'The Dangers of Public Wi-Fi and How to Stay Secure\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Using public Wi-Fi to access social media accounts can expose your data to cybercriminals. To stay secure:\n',
      ),
      TextSpan(text: '• Avoid logging into social media accounts over public Wi-Fi unless using a VPN.\n'),
      TextSpan(text: '• Log in through cellular data when possible.\n\n'),

      // Social Engineering
      TextSpan(
        text: 'Understanding Social Engineering and Impersonation Attacks\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Cybercriminals may impersonate people or companies to gain access to your information. Watch out for:\n',
      ),
      TextSpan(text: '• Unsolicited messages asking for passwords or financial info.\n'),
      TextSpan(text: '• Fake friend requests from unknown or duplicate accounts.\n'),
      TextSpan(text: '• Suspicious links or attachments sent via DMs.\n\n'),

      // Privacy Settings
      TextSpan(
        text: 'The Importance of Privacy Settings and Controlling Shared Information\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Most platforms allow control over what others can see. To improve security:\n',
      ),
      TextSpan(text: '• Regularly review and update privacy settings.\n'),
      TextSpan(text: '• Limit the amount of personal info shared publicly.\n'),
      TextSpan(text: '• Disable location tracking unless needed.\n\n'),

      // Fake Profiles
      TextSpan(
        text: 'Avoiding Fake Profiles and Scams\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Fake accounts are common. Stay cautious by:\n',
      ),
      TextSpan(text: '• Being careful with friend requests from strangers.\n'),
      TextSpan(text: '• Checking for signs like limited posts or generic photos.\n'),
      TextSpan(text: '• Reporting and blocking fake profiles.\n\n'),

      // Oversharing
      TextSpan(
        text: 'Risks of Sharing Personal Information Online\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Too much personal info can make you a target for identity theft or stalking. Avoid sharing:\n',
      ),
      TextSpan(text: '• Your full name, address, or phone number.\n'),
      TextSpan(text: '• Travel plans or daily routines.\n\n'),

      // Bots
      TextSpan(
        text: 'Understanding Bots and Automated Accounts\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Bots can spread scams or misinformation. Look out for:\n',
      ),
      TextSpan(text: '• Minimal profile info.\n'),
      TextSpan(text: '• Repetitive or spam-like content.\n'),
      TextSpan(text: '• Auto-generated messages with suspicious links.\n\n'),

      // Identity Theft
      TextSpan(
        text: 'Recognizing and Preventing Identity Theft\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Cybercriminals may impersonate you using your public data. To prevent it:\n',
      ),
      TextSpan(text: '• Avoid sharing your birthdate or home address.\n'),
      TextSpan(text: '• Monitor your online presence.\n'),
      TextSpan(text: '• Report impersonators quickly.\n\n'),

      // Deepfakes
      TextSpan(
        text: 'Protecting Against Deepfake and AI-Based Scams\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Deepfakes can be convincing and dangerous. Protect yourself by:\n',
      ),
      TextSpan(text: '• Verifying video/image sources.\n'),
      TextSpan(text: '• Being cautious even if a message looks like it’s from someone you know.\n\n'),

      // Links and Third-Party Apps
      TextSpan(
        text: 'Safe Practices for Clicking Links and Using Third-Party Apps\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Third-party apps and unknown links can expose your account. Best practices include:\n',
      ),
      TextSpan(text: '• Avoid clicking on shortened or unverified URLs.\n'),
      TextSpan(text: '• Use only trusted apps and limit permissions.\n'),
      TextSpan(text: '• Regularly remove unused third-party apps.\n\n'),

      // Hacked Account
      TextSpan(
        text: 'What to Do If Your Account Is Hacked\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Follow these steps if your account is compromised:\n',
      ),
      TextSpan(text: '1. Change your password immediately.\n'),
      TextSpan(text: '2. Enable Two-Factor Authentication.\n'),
      TextSpan(text: '3. Check account settings for unauthorized changes.\n'),
      TextSpan(text: '4. Report the issue to the platform.\n'),
      TextSpan(text: '5. Notify your friends of suspicious messages.\n\n'),

      // Conclusion
      TextSpan(
        text: 'Conclusion\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Staying safe on social media requires awareness and proactive security measures. By creating strong passwords, enabling 2FA, recognizing scams, and limiting personal information sharing, you can reduce the risks of cyber threats. Regularly reviewing your privacy settings and being cautious about online interactions will help protect your identity and ensure a safer social media experience.\n',
      ),
    ],
    'Recognizing Social Engineering': [
      TextSpan(
        text: 'Introduction to Recognizing Social Engineering and Common Types of Malware Attacks\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),

      // Intro
      TextSpan(
        text:
        'In today’s interconnected world, cybercriminals use both technological and psychological tactics to exploit individuals and organizations. One of the most dangerous tactics is social engineering, which relies on manipulating people into revealing sensitive information or performing actions that compromise security. Often, social engineering is used to deliver malware—malicious software designed to harm, exploit, or gain unauthorized access to systems. This guide introduces key concepts, common attack types, and practical steps to recognize and prevent them.\n\n',
      ),

      // Social Engineering
      TextSpan(
        text: '🧠 What is Social Engineering?\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Social engineering is the art of deceiving people to gain confidential information or access. Instead of hacking computer systems, attackers exploit human psychology through trust, fear, urgency, or curiosity. These tactics are used to trick people into clicking malicious links, opening harmful attachments, or providing sensitive data like passwords or credit card numbers.\n',
      ),
      TextSpan(
        text: 'Common Social Engineering Techniques:\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(text: '• Phishing: Sending fraudulent emails, texts, or messages that appear to be from legitimate sources, urging recipients to click a link or provide personal information.\n'),
      TextSpan(text: '• Spear Phishing: A targeted form of phishing aimed at a specific individual or organization using personalized information to increase credibility.\n'),
      TextSpan(text: '• Whaling: Targeting high-profile individuals (e.g., executives) with sophisticated phishing attempts.\n'),
      TextSpan(text: '• Pretexting: Creating a fabricated scenario (e.g., pretending to be tech support) to trick someone into providing information.\n'),
      TextSpan(text: '• Baiting: Offering something enticing (like a free download or USB drive) to lure victims into compromising their systems.\n'),
      TextSpan(text: '• Tailgating: Physically following someone into a restricted area by exploiting politeness or authority.\n\n'),

      // Malware
      TextSpan(
        text: '🛡️ Understanding Malware and Its Types\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Malware (short for malicious software) is designed to disrupt, damage, or gain unauthorized access to devices and networks. Attackers often use social engineering to convince victims to download or run malware.\n',
      ),
      TextSpan(
        text: 'Common Types of Malware:\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(text: '• Viruses: Malicious code that attaches to files and spreads when the files are opened.\n'),
      TextSpan(text: '• Worms: Malware that spreads through networks without user action.\n'),
      TextSpan(text: '• Trojan Horses: Malicious software disguised as legitimate programs; once installed, it can steal data or allow unauthorized access.\n'),
      TextSpan(text: '• Ransomware: Encrypts files and demands payment to restore access.\n'),
      TextSpan(text: '• Spyware: Secretly monitors user activity, capturing information like keystrokes and login credentials.\n'),
      TextSpan(text: '• Adware: Displays unwanted ads, sometimes containing hidden malware.\n'),
      TextSpan(text: '• Rootkits: Hides malware deep within systems, making it hard to detect.\n\n'),

      // Recognizing Attacks
      TextSpan(
        text: '🕵️‍♀️ Recognizing Social Engineering and Malware Attacks\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'Warning Signs of an Attack:\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(text: '• Unexpected emails asking for sensitive information or urging immediate action.\n'),
      TextSpan(text: '• Suspicious links or attachments, especially from unknown senders.\n'),
      TextSpan(text: '• Offers that seem “too good to be true.”\n'),
      TextSpan(text: '• Pop-up ads claiming you’ve won a prize or need to download something urgently.\n'),
      TextSpan(text: '• Phone calls from “officials” demanding information or payment.\n'),
      TextSpan(text: '• Unknown devices (like USB drives) found in public areas.\n\n'),
      TextSpan(
        text: 'How Malware Spreads:\n',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(text: '• Clicking on malicious links or pop-ups.\n'),
      TextSpan(text: '• Opening infected email attachments.\n'),
      TextSpan(text: '• Downloading software from untrustworthy websites.\n'),
      TextSpan(text: '• Using compromised USB drives or public charging stations.\n'),
      TextSpan(text: '• Visiting malicious or compromised websites.\n\n'),

      // Protection
      TextSpan(
        text: '📝 Protecting Yourself and Your Organization\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '✅ Verify Before Clicking: Always check the sender’s email address, hover over links to see the destination, and be wary of urgent or emotional language.\n'),
      TextSpan(text: '✅ Use Strong Passwords: Combine letters, numbers, and symbols; use a password manager.\n'),
      TextSpan(text: '✅ Enable Two-Factor Authentication (2FA): Adds an extra layer of security beyond passwords.\n'),
      TextSpan(text: '✅ Regular Software Updates: Keep your devices and antivirus software up to date to fix security vulnerabilities.\n'),
      TextSpan(text: '✅ Educate Yourself and Others: Awareness is your first line of defence against social engineering.\n'),
      TextSpan(text: '✅ Don’t Trust Unknown Devices: Never plug in found USB drives or use public charging stations without data blockers.\n'),
      TextSpan(text: '✅ Report Suspicious Activity: Notify your IT department or service providers of suspected phishing or malware attempts.\n\n'),

      // Myths
      TextSpan(
        text: '🚫 Common Myths About Social Engineering and Malware\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '❌ “I can spot a fake email easily.” – Attackers use advanced tactics that look highly convincing.\n'),
      TextSpan(text: '❌ “Only large companies are targeted.” – Individuals and small businesses are often targeted due to weaker security.\n'),
      TextSpan(text: '❌ “Antivirus software protects against everything.” – Antivirus helps, but human vigilance is essential.\n'),
      TextSpan(text: '❌ “If something happens, I’ll notice right away.” – Some malware operates silently for weeks or months.\n\n'),

      // Conclusion
      TextSpan(
        text: '🏆 Conclusion\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Social engineering attacks exploit human psychology, making awareness and caution critical defences. Recognizing phishing attempts, avoiding suspicious downloads, using strong passwords, and staying informed are key to safeguarding your personal and professional data. By understanding common malware types and how they spread, you can better protect yourself and your devices from cyber threats.\n\nStay alert. Stay secure. 🛡️\n',
      ),
    ],
    'General Data Protection Regulation': [
      TextSpan(
        text: 'Introduction to General Data Protection Regulation (GDPR)\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'The General Data Protection Regulation (GDPR) is a comprehensive data protection law that was enacted by the European Union (EU) to safeguard the privacy and personal data of individuals within the EU and the European Economic Area (EEA). The regulation was officially adopted on April 27, 2016, and became enforceable on May 25, 2018. GDPR was designed to address the growing concerns about the way personal data is collected, stored, processed, and shared in the digital age.\n\n'
            'GDPR applies not only to organizations within the EU but also to any organization that processes the personal data of EU citizens, regardless of the company’s location. As a result, it has become a global standard for data protection practices.\n\n',
      ),
      TextSpan(
        text: 'Key Concepts and Principles of GDPR\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text: '1. Personal Data: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Under GDPR, personal data is defined as any information that relates to an identified or identifiable individual. This includes not only basic data such as names and addresses but also more sensitive information, such as health data, political opinions, and biometric data.\n',
      ),
      TextSpan(
        text: '2. Lawful Bases for Data Processing:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: 'GDPR requires that personal data can only be processed if there is a lawful basis for doing so. The six lawful bases for processing personal data are:\n'
            '• Consent: The individual has given explicit consent for the processing of their data.\n'
            '• Contractual necessity: The processing is necessary for the performance of a contract with the individual.\n'
            '• Legal obligation: The processing is required to comply with the law.\n'
            '• Vital interests: The processing is necessary to protect someone’s life.\n'
            '• Public task: The processing is necessary to carry out an official function or task.\n'
            '• Legitimate interests: The processing is necessary for legitimate interests pursued by the data controller, provided that this does not override the rights and freedoms of the individual.\n\n',
      ),
      TextSpan(
        text: '3. Rights of Individuals:\n',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'GDPR provides several important rights to individuals regarding their personal data:\n'
            '• Right to Access: Individuals can request access to their personal data and receive a copy of it.\n'
            '• Right to Rectification: Individuals can request the correction of inaccurate or incomplete personal data.\n'
            '• Right to Erasure: Also known as the "right to be forgotten," individuals can request the deletion of their personal data in certain circumstances.\n'
            '• Right to Restrict Processing: Individuals can request that their personal data be restricted from processing.\n'
            '• Right to Data Portability: Individuals can request their personal data to be transferred to another organization in a structured, commonly used format.\n'
            '• Right to Object: Individuals can object to the processing of their personal data in certain situations, including direct marketing.\n\n',
      ),
      TextSpan(
        text: '4. Consent: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'One of the most important elements of GDPR is the requirement for informed, explicit consent from individuals before their personal data is collected or processed. Consent must be given freely, be specific, informed, and unambiguous. Individuals must also be informed of the purpose for data processing and be able to withdraw their consent at any time.\n\n',
      ),
      TextSpan(
        text: '5. Data Protection by Design and by Default: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Organizations must implement measures to ensure that personal data is protected from the outset, integrating data protection principles into their systems and practices. This includes limiting the amount of data collected and ensuring it is stored securely.\n\n',
      ),
      TextSpan(
        text: '6. Data Protection Officer (DPO): ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Organizations that process large amounts of personal data or special categories of data must appoint a Data Protection Officer (DPO). The DPO is responsible for overseeing data protection compliance and advising the organization on GDPR-related matters.\n\n',
      ),
      TextSpan(
        text: '7. Data Processing Agreement: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'When outsourcing data processing tasks to third parties (data processors), organizations must have a Data Processing Agreement (DPA) in place to ensure that the processor complies with GDPR obligations and protects personal data.\n\n',
      ),
      TextSpan(
        text: '8. Data Breaches: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'GDPR requires organizations to report data breaches to the relevant supervisory authority within 72 hours if there is a risk to the rights and freedoms of individuals. A data breach is an incident where personal data is accidentally or unlawfully disclosed, accessed, lost, or altered.\n\n',
      ),
      TextSpan(
        text: 'Key GDPR Obligations for Organizations\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text: '1. Accountability: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'Organizations are responsible for ensuring compliance with GDPR and must be able to demonstrate their compliance through documentation and audits.\n',
      ),
      TextSpan(
        text: '2. Data Protection Impact Assessment (DPIA): ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'A DPIA is a process used to evaluate the potential risks to personal data when introducing new projects or processing activities. It is required when processing is likely to result in a high risk to individuals\' rights and freedoms.\n',
      ),
      TextSpan(
        text: '3. International Data Transfers: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'GDPR imposes restrictions on transferring personal data outside the EU and EEA. Personal data can only be transferred to countries that offer an adequate level of data protection, or appropriate safeguards must be in place, such as standard contractual clauses or binding corporate rules.\n',
      ),
      TextSpan(
        text: '4. Fines and Penalties: ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text:
        'GDPR allows for significant fines for non-compliance. The maximum fine can be up to €20 million or 4% of an organization’s global annual turnover, whichever is higher. The fines are intended to encourage organizations to prioritize data protection and comply with the regulation.\n\n',
      ),
      TextSpan(
        text: 'The Importance of GDPR\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'GDPR provides individuals with more control over their personal data and ensures that their privacy is protected in an increasingly data-driven world. For organizations, compliance with GDPR is not only a legal requirement but also a means of building trust with customers, improving data security, and mitigating risks associated with data processing.\n\n',
      ),
      TextSpan(
        text: 'Frequently Asked Questions (FAQs) About GDPR\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        '• Does GDPR apply only to EU companies?\n'
            '  No, GDPR applies to any organization, regardless of location, that processes the personal data of EU citizens.\n'
            '• What is required to process personal data under GDPR?\n'
            '  Organizations must have a lawful basis for processing personal data, and individuals must be informed of how their data will be used.\n'
            '• Can organizations use personal data for any purpose under GDPR?\n'
            '  No, organizations must collect data for specified, legitimate purposes and cannot use it in ways that are incompatible with those purposes.\n'
            '• What happens if a data subject withdraws consent?\n'
            '  If consent is withdrawn, organizations must stop processing the individual’s personal data unless there is another lawful basis for the processing.\n'
            '• Is it mandatory to have a Data Protection Officer?\n'
            '  A Data Protection Officer is required for certain organizations, such as those that process large volumes of sensitive data or perform large-scale monitoring of individuals.\n'
            '• How can individuals exercise their rights under GDPR?\n'
            '  Individuals can exercise their rights by contacting the organization that holds their data. Organizations are required to respond within a reasonable timeframe (usually 30 days).\n\n',
      ),
      TextSpan(
        text: 'Conclusion\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'The General Data Protection Regulation (GDPR) represents a major shift in how organizations handle personal data. By understanding the key principles, rights, and obligations outlined in GDPR, both individuals and organizations can ensure that data is protected, handled responsibly, and used transparently. It is essential for businesses to stay compliant with GDPR to avoid potential penalties and to build trust with their customers.\n\n'
            'This introductory page has covered the fundamental topics of GDPR, including data protection principles, rights of individuals, lawful bases for data processing, and obligations for organizations. The following questions will test your understanding of these concepts, ensuring that you are well-versed in GDPR practices and principles.\n',
      ),
    ],
    'IoT and Ai in Cybersecurity':
    [
      TextSpan(
        text: 'Introduction to IoT and AI in Cybersecurity\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      TextSpan(
        text:
        'The rapid adoption of Internet of Things (IoT) devices has transformed industries and daily life, offering convenience and efficiency in various applications. However, the increased connectivity of these devices also introduces significant cybersecurity risks. To mitigate these risks, Artificial Intelligence (AI) plays a crucial role in enhancing security measures.\n\n',
      ),
      TextSpan(
        text: 'Understanding IoT\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        'IoT, or the Internet of Things, refers to a network of interconnected devices that communicate and share data over the internet. These devices range from smart thermostats and security cameras to industrial sensors and medical devices. The primary challenge in IoT security stems from their limited processing power, default or weak passwords, and lack of frequent updates, making them attractive targets for cyberattacks.\n\n',
      ),
      TextSpan(
        text: 'Common Security Risks in IoT\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        '1. Weak Authentication - Many IoT devices use default passwords, making them vulnerable to attacks.\n'
            '2. Data Privacy Concerns - Unencrypted communication can expose sensitive information.\n'
            '3. DDoS Attacks - Cybercriminals often hijack IoT devices to form botnets and launch distributed denial-of-service (DDoS) attacks.\n'
            '4. Zero-Day Attacks - Exploiting unknown vulnerabilities in IoT devices before a fix is available.\n\n',
      ),
      TextSpan(
        text: 'Role of AI in IoT Cybersecurity\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        'AI is an essential tool in cybersecurity, offering advanced threat detection and automated responses to attacks. Key applications of AI in cybersecurity include:\n\n'
            '1. Anomaly Detection - AI-powered Intrusion Detection Systems (IDS) monitor network traffic and identify unusual activity that may indicate cyber threats.\n'
            '2. Machine Learning Models - AI utilizes decision trees, deep learning, and recurrent neural networks (RNNs) to classify cybersecurity threats.\n'
            '3. Phishing Prevention - AI analyzes email and communication patterns to detect phishing attempts before users fall victim.\n'
            '4. Malware Detection - AI-driven systems identify and respond to malware threats more efficiently than traditional signature-based methods.\n'
            '5. Predicting and Preventing Zero-Day Attacks - AI analyzes past attack patterns to predict new threats and proactively mitigate risks.\n\n',
      ),
      TextSpan(
        text: 'Notable Cybersecurity Threats in IoT\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        '1. Mirai Botnet Attack (2016) - One of the largest IoT botnet attacks, which disrupted major internet services worldwide.\n'
            '2. Adversarial Machine Learning - Cybercriminals attempt to manipulate AI models by feeding them misleading data to bypass security measures.\n'
            '3. IoT Protocol Vulnerabilities - HTTP and Telnet connections are less secure than encrypted alternatives like HTTPS and MQTT.\n\n',
      ),
      TextSpan(
        text: 'Best Practices for Securing IoT Devices\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        '- Change Default Passwords - Always update factory-set credentials to strong, unique passwords.\n'
            '- Use Secure Communication Protocols - Opt for HTTPS or MQTT instead of unencrypted alternatives.\n'
            '- Enable Automatic Updates - Regular updates help patch security vulnerabilities.\n'
            '- Implement AI-Powered Security Tools - Solutions like Darktrace use AI to detect and respond to threats in real time.\n'
            '- Adopt Edge Computing for Security - Processing data at the edge of the network enhances security by reducing exposure to centralized attack points.\n\n',
      ),
      TextSpan(
        text: 'Conclusion\n\n',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      TextSpan(
        text:
        'As IoT adoption continues to rise, the integration of AI in cybersecurity is essential for detecting and preventing cyber threats. AI-powered security solutions provide enhanced threat intelligence, automated defenses, and adaptive security measures, making them a crucial component in safeguarding IoT ecosystems. By following best practices and leveraging AI-driven cybersecurity solutions, organizations and individuals can better protect their IoT devices from emerging threats.\n',
      ),
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
          backgroundColor: context.watch<ThemeProvider>().selectedBackgroundColor,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: introductions[topic] ??
                          [const TextSpan(text: "Introduction not available.")],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xff6200EE)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          tableName: tableName,
                          difficulty: difficulty,
                        ),
                      ),
                    );
                  },
                  child: const Text("Start Quiz"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
