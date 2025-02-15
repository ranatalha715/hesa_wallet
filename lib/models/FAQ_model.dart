class FAQModel {
  final String question;
  final String answer;
  bool isSelected;

  FAQModel({required this.question, required this.answer, this.isSelected = false});
}

List<FAQModel> faqList = [
  FAQModel(
    question: "What is Hesa Wallet?",
    answer: "Hesa Wallet is a custodial Web3 wallet that allows users to transact with trusted blockchain networks within the AlMajra Blockchain Ecosystem. It is crypto-free, meaning users cannot buy, store, or transact with cryptocurrencies—all transactions are conducted using fiat payments.",
  ),
  FAQModel(
    question: "How is Hesa Wallet different from other Web3 wallets?",
    answer:"""Crypto-Free: Unlike traditional Web3 wallets, Hesa Wallet does not support cryptocurrencies.
Custodial Wallet: Hesa Wallet manages private keys on behalf of users, ensuring secure transactions.
Fiat Payments Only: Users make payments using fiat currency rather than cryptocurrency.
Integrated with MJR B-01 Blockchain: Transactions occur within a regulated and trusted blockchain network.
      """,
  ),
  FAQModel(
    question: "Do I need cryptocurrency to use Hesa Wallet?",
    answer: "No, Hesa Wallet is crypto-free. Users cannot purchase, store, or transact cryptocurrencies—all payments are processed using fiat currency.",
  ),
];

List<FAQModel> faqSecurity=[
  FAQModel(
    question: "How do I create an account on Hesa Wallet?",
    answer: "Simply download the app, follow the registration process, and verify your identity using your mobile number.",
  ),
  FAQModel(
    question: "What happens if I lose access to my account?",
    answer: "Hesa Wallet provides an account recovery process using identity verification and mobile number authentication. Make sure your contact information is up to date to facilitate recovery.",
  ),
  FAQModel(
    question: "Is my private key stored securely?",
    answer: "Yes, Hesa Wallet is a custodial wallet, meaning your private keys are securely managed by Hesa Wallet. You do not have access to your private keys, but your transactions remain secure and encrypted.",
  ),
  FAQModel(
    question: "How do I secure my Hesa Wallet account?",
    answer: """Use a strong password and never share your credentials.
  Enable two-factor authentication (2FA) if available.
  Be cautious of phishing attempts and suspicious links.""",
  ),
];

List<FAQModel> faqTnxPay=[
FAQModel(
question: "How do I make a payment using Hesa Wallet?",
answer: """Initiate a transaction from a Web3 application.
Authenticate the payment in Hesa Wallet using your preferred fiat payment method.
Once authorized, Hesa Wallet will cryptographically sign the transaction and submit it to the MJR B-01 Blockchain Network.""",
),
  FAQModel(
    question: "How are transactions authenticated?",
    answer: """For payable transactions: Users authenticate a transaction by making a fiat payment.
For non-payable transactions: Users authenticate by verifying an OTP code sent to their registered mobile number.""",
  ),
  FAQModel(
    question: "What types of transactions can I perform with Hesa Wallet?",
    answer: """Purchasing digital assets from Web3 applications.
Transferring digital assets to other users within the MJR B-01 Blockchain Network.""",
  ),
  FAQModel(
    question: "Can I reverse or cancel a transaction?",
    answer: """No. Once a transaction is cryptographically signed and submitted to the blockchain, it is final and irreversible.""",
  ),
  FAQModel(
    question: "What are network fees?",
    answer: """Network fees cover the cost of processing transactions on the MJR B-01 Blockchain Network. These are not gas fees but are required to ensure smooth transaction execution.""",
  ),
];

List<FAQModel> faqPaywithdraw=[
  FAQModel(
    question: "How do I withdraw funds from my Hesa Wallet?",
    answer: """Users can register their local bank details and IBAN to receive payouts from transactions, such as NFT sales or creator royalties.""",
  ),
  FAQModel(
    question: "How long does it take to receive a payout?",
    answer: "Processing times depend on banking institutions, but payouts are usually processed within [expected time, e.g., 1-5 business days].",
  ),
  FAQModel(
    question: "Are there any fees for payouts?",
    answer: "Yes, a 4% + 2 SAR fee applies to all payout transactions.",
  ),
];

List<FAQModel> faqConnection=[
  FAQModel(
    question: "How do I connect Hesa Wallet to a Web3 application?",
    answer: """Open the Web3 application you wish to connect to.
  Select Hesa Wallet as the preferred wallet.
  Approve the connection request in Hesa Wallet.""",
  ),
  FAQModel(
    question: "Can Web3 applications access my personal data?",
    answer: """No. Web3 applications can only access your wallet ID, username, and profile icon. 
They cannot access your mobile number, ID number, full name, or email address.""",
  ),
  FAQModel(
    question: "How do I disconnect a Web3 application from my Hesa Wallet?",
    answer: "You can manage and disconnect Web3 applications at any time via the ‘Connected Apps’ page in Hesa Wallet.",
  ),
];

List<FAQModel> faqCompilanceSecurity=[
  FAQModel(
    question: "Is Hesa Wallet regulated?",
    answer: "Hesa Wallet is currently undergoing regulatory approvals in Saudi Arabia and follows compliance with financial and AML (Anti-Money Laundering) regulations.",),
  FAQModel(
    question: "What happens if a Web3 application mismanages my data?",
    answer: "Hesa Wallet is not responsible for any data breaches, losses, or unauthorized activities caused by third-party Web3 applications. Users should conduct their own due diligence before connecting their wallet.",
  ),
  FAQModel(
    question: "What security measures does Hesa Wallet use?",
    answer: """Secure custodial key management to protect user assets."
 "Encrypted transactions for privacy and security.
 Regulatory compliance to meet Saudi Arabian financial standards.""",
  ),
];

List<FAQModel> faqSupport=[
  FAQModel(
    question: "What should I do if I experience issues with a transaction?",
    answer: "If a transaction fails or does not process correctly, contact Hesa Wallet Support at support@hesawallet.com with the transaction details.",
  ),
  FAQModel(
    question: "How can I report unauthorized activity on my account?",
    answer:"""If you notice any suspicious activity, immediately: Change your password and secure your account.
  Contact Hesa Wallet support to report the issue.""",
  ),
  FAQModel(
    question: "How do I contact Hesa Wallet support?",
    answer: "You can reach us at: support@hesawallet.com",
  ),
];