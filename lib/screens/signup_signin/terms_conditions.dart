import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animated_checkmark/animated_checkmark.dart';
import 'package:hesa_wallet/constants/configs.dart';
import 'package:hesa_wallet/providers/auth_provider.dart';
import 'package:hesa_wallet/widgets/animated_loader/animated_loader.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' as OS;
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/main_header.dart';

class TermsAndConditions extends StatefulWidget {

  static const routeName = '/TermsAndConditions';
  bool? fromSignup;
    TermsAndConditions({Key? key,  this.fromSignup=true}) : super(key: key);

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  List<String> accountDefinitions = [
    'Hesa Wallet allows its users to connect and interact with Web3 that are part of and trusted by the AlMajra Blockchain Networks Ecosystem. Hesa Wallet is a crypto-free wallet, meaning users cannot purchase, transact, or store cryptocurrencies using Hesa Wallet. All transactions are processed using fiat payments. Hesa Wallet is integrated with the MJR B-01 Blockchain Network, which is operated by AlMajra Blockchain Networks by Limar Global Technologies Company.'
        .tr(),
    'Hesa Wallet is a custodial Web3 wallet, meaning Hesa Wallet manages private keys on behalf of users. Users do not have direct control or access to their private keys. However, in case of account access issues, Hesa Wallet provides a recovery process that includes identity verification measures to help users regain access. Users are encouraged to ensure their account information is accurate and up to date to facilitate the recovery process.'
        .tr(),
    'Hesa Wallet does not store or hold fiat money. Instead, it facilitates transactions of digital assets on the MJR B-01 Blockchain Network, operated by AlMajra Blockchain Platform.'
    'Hesa Wallet is not a financial institution and does not provide banking, lending, or investment services. It solely acts as a facilitator for Web3 transactions within the MJR B-01 Blockchain Ecosystem.',
    'You must be at least 18 years old and legally capable of entering into a binding contract under the laws of Saudi Arabia.',
    'You confirm that you are not restricted by sanctions or legal prohibitions from using Web3 services in Saudi Arabia or any other applicable jurisdiction.',
    'You are responsible for ensuring that your use of Hesa Wallet complies with local laws and regulations in your jurisdiction.',
    'Web3 App Connectivity: Users can connect Hesa Wallet to third-party decentralized applications (dApps) within the MJR B-01 Blockchain Ecosystem.',
    'Custodial Private Key Management: Hesa Wallet securely stores and manages private keys for users.',
    'Transaction Execution: Web3 applications send transaction requests to Hesa Wallet, which users can approve or reject.',
    'Network Fees Instead of Gas Fees: Transactions do not incur traditional "gas fees"; instead, network fees cover operational costs of executing transactions within MJR B-01 Blockchain Network.',
    'Payouts & Withdrawals: Users can register local bank details and IBAN to receive payouts (e.g., NFT sales, creator royalties)',
    'Connected Apps Management: Users can view, manage, and disconnect Web3 applications at any time.',
    'Users do not manage their own private keys. Hesa Wallet securely holds and manages all private keys.',
    'Users acknowledge that they are entrusting Hesa Wallet to handle cryptographic key management on their behalf.',
    'Hesa Wallet implements strict security measures to protect private keys, but it is not liable for any loss due to hacks, unauthorized access, or network vulnerabilities.',
    'Hesa Wallet employs a secure custodial model where user private keys are managed and stored securely.',
    'Users must explicitly authorize all transactions before they are signed and executed.',
    'For payable transactions, users authenticate a transaction by making a payment.',
    'For non-payable transactions, users authenticate by verifying an OTP code sent to their registered mobile number.',
    'Once either authentication method is verified, Hesa Wallet uses its custodial key management system to cryptographically sign the transaction and submit it to the MJR B-01 Blockchain Network.',
    'Transactions may involve the purchase of digital assets or the transfer of digital assets to other users.',
    'Validating the cryptographic signature.',
    'Ensuring compliance with smart contract conditions.',
    'Confirming that the transaction follows network consensus rules before execution.',
    'Transactions are cryptographically signed to authenticate and execute a blockchain transaction, ensuring security and integrity.',
    'Signed transactions are final and irreversible once processed by the blockchain network.',
    'Hesa Wallet is not responsible for unauthorized transactions executed due to compromised user credentials, phishing attacks, or unauthorized access.',
    'Hesa Wallet reserves the right to apply the following fees:',
    '4% + 2 SAR on all payment transactions processed within Hesa Wallet.',
    '4% + 2 SAR on all payout transactions to users, local bank accounts.',
  'Network fees for transaction execution on MJR B-01 Blockchain Network.',
    'Users acknowledge that fees may be updated periodically, and continued use of Hesa Wallet constitutes acceptance of updated fees.',
    'Users must take reasonable measures to protect their account credentials and wallet access.',
    'Users are solely responsible for:',
    'Verifying transaction details before approval. Hesa Wallet does not automatically reverse erroneous transactions. However, users may submit a dispute request within 7 days of the transaction by providing relevant evidence for review. The final decision on disputes shall be at the sole discretion of Hesa Wallets compliance team',
    'Ensuring they are interacting with legitimate and trustworthy Web3 applications.',
    'Securing their login information from unauthorized access.',
    'Hesa Wallet is not liable for:',
    'Unauthorized account access due to user negligence',
    'Loss of digital assets due to third-party breaches or blockchain vulnerabilities.',
    'Errors in transactions caused by incorrect wallet IDs or user mistakes',
    'Users acknowledge that Hesa Wallet is not responsible for:',
    'The security, privacy, or reliability of third-party Web3 applications.',
    'Any losses or misuse of data by Web3 applications.',
    'Errors or failures in transaction execution caused by external dApps.',
    'Users should exercise caution and due diligence before connecting their wallet to any third-party applications.',
    'Once a transaction is approved by a user, it is submitted to the MJR B-01 Blockchain Network for processing.',
    'There are no traditional "gas fees"; instead, network fees cover the cost of blockchain transaction execution which belong to the network itserlf “MJR B-01”.',
    'Users acknowledge that blockchain transactions are irreversible once executed.',
    'Users can register their local bank details and IBAN to receive payouts from Web3 applications.',
    'Hesa Wallet does not hold or manage fiat funds—payouts are processed via external banking institutions.',
    'Hesa Wallet is not responsible for:',
    'Delays or failures in payout processing by banks.',
    'Bank-imposed transaction fees or currency conversion charges.',
    'Hesa Wallet is undergoing regulatory approvals in Saudi Arabia and may be subject to future operational changes.'
    'Hesa Wallet complies with AML (Anti-Money Laundering) regulations and reserves the right to:',
    'Suspend accounts suspected of fraudulent or illegal activities.',
    'Report suspicious transactions to Saudi regulatory authorities.'
    'Users will be notified of suspension or termination and have the right to appeal the decision through a formal dispute resolution process, which includes submitting a written appeal to Hesa Wallets compliance department within 14 days of receiving notice. The appeal will be reviewed, and a final decision will be communicated within 30 days. Hesa Wallet reserves the right to suspend or terminate accounts for the following reasons:',
    'Legal violations or regulatory non-compliance.',
    'Suspected fraudulent transactions.',
    'Government orders or law enforcement requirements.',
    'Users may terminate their accounts at any time by disconnecting all linked applications and discontinuing wallet use.',
    'These T&C are governed by the laws of the Kingdom of Saudi Arabia.',
    'Any disputes shall be resolved through mediation first, followed by arbitration in Riyadh, KSA, under the Saudi Center for Commercial Arbitration (SCCA).',
    'For inquiries, disputes, or support, contact us at: 📧 support@hesawallet.com',
    'Riyadh, Kingdom of Saudi Arabia',
  ];

  bool _isChecked = false;
  bool isButtonActive = false;
  var _isLoading = false;
  var _isinit= true;

  final ScrollController scrollController = ScrollController();

  void _updateButtonState() {
    setState(() {
      isButtonActive;
    });
  }

  String fcmToken = 'Waiting for FCM token...';

  generateFcmToken() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getToken().then((newToken) {
      print("fcm===" + newToken!);
      setState(() {
        fcmToken = newToken;
      });
    });
  }

  @override
  void initState() {
    generateFcmToken();

    // TODO: implement initState
    Timer.periodic(Duration(seconds: 1), (timer) async {

    });
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeNotifier, child) {
      return Stack(
        children: [
          WillPopScope(
              onWillPop: () async {
                widget.fromSignup==true ? Navigator.pop(context) : Navigator.pop(context);
                // widget.fromSignup==true ? exit(0) : Navigator.pop(context);
                return true;
              },
            child: Scaffold(
              backgroundColor: themeNotifier.isDark
                  ? AppColors.backgroundColor
                  : AppColors.textColorWhite,
              body: Column(
                children: [
                  MainHeader(title: 'Terms & Conditions'.tr(),
                  handler: (){
                    widget.fromSignup==true ? Navigator.pop(context) : Navigator.pop(context);
                    // widget.fromSignup==true ? exit(0) : Navigator.pop(context);

                  },
                  ),
                  Expanded(
                    child: Container(
                      height: 85.h,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  Text(
                                    "Last updated: February 2025".tr(),
                                    style: TextStyle(
                                        color: AppColors.textColorWhite,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter'),
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  Text(
                                    'Welcome to Hesa Wallet ("Hesa Wallet," "we," "our," or "us"), a custodial Web3 wallet operated by Limar Global Technologies Company, with commercial registration number #1010256003. These Terms and Conditions ("T&C") govern your access to and use of Hesa Wallet, including its services, payment processing, and blockchain interactions. \nHesa Wallet is currently in its pilot phase and undergoing regulatory approvals in the Kingdom of Saudi Arabia (KSA), which are expected to be completed within [anticipated timeframe, e.g., 6-24 months]. These terms may be updated to comply with evolving legal and regulatory requirements. \nBy using Hesa Wallet, you ("User," "you," or "your") agree to abide by these Terms and Conditions. If you do not agree, you must immediately discontinue use of Hesa Wallet.'
                                        .tr(),
                                    style: TextStyle(
                                        height: 1.4,
                                        color: AppColors.textColorWhite,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.7.sp,
                                        fontFamily: 'Inter'),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    controller: scrollController,
                                    itemCount: accountDefinitions.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: 4.0, right: 8.0),
                                            child: Icon(
                                              Icons.fiber_manual_record,
                                              size: 7.sp,
                                              color: AppColors.textColorWhite,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(bottom: 12),
                                              child: Text(
                                                accountDefinitions[index],
                                                style: TextStyle(
                                                    height: 1.4,
                                                    color: AppColors.textColorWhite,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 10.2.sp,
                                                    fontFamily: 'Inter'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if(widget.fromSignup == true)
                          Positioned(
                            left: 0,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              color: themeNotifier.isDark
                                  ? AppColors.backgroundColor
                                  : AppColors.textColorWhite,
                              child: Padding(
                                padding:  EdgeInsets.only(left:20.sp, bottom: 20.sp, right: 20.sp),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 1.h,
                                    ),
                                    // Expanded(child: SizedBox()),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.only(left: 4.sp),
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _isChecked = !_isChecked;
                                            }),
                                            child:
                                            Container(
                                              height: 2.4.h,
                                              width: 2.4.h,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(2)),
                                              child:
                                              AnimatedContainer(
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  height: 2.4.h,
                                                  width: 2.4.h,
                                                  decoration: BoxDecoration(
                                                    color: _isChecked ? AppColors.hexaGreen : Colors.transparent, // Animate the color
                                                    border: Border.all(
                                                        color: _isChecked ?AppColors.hexaGreen : AppColors.textColorWhite,
                                                        width: 1),
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                  child:  Checkmark(
                                                    checked: _isChecked,
                                                    indeterminate: false,
                                                    size: 11.sp,
                                                    color: Colors.black,
                                                    drawCross: false,
                                                    drawDash: false,
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        Expanded(
                                          child:
                                          Container(
                                            child: Text(
                                              'I understand the general terms and statements mentioned in this disclaimer and agree to continue'
                                                  .tr(),
                                              style: TextStyle(
                                                  color: AppColors.textColorWhite,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 9.sp,
                                                  fontFamily: 'Inter'),
                                              maxLines: 2,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    AppButton(
                                        title: 'Accept'.tr(),
                                        isactive:
                                        _isChecked,
                                        handler: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          final  finalResult = await Provider.of<AuthProvider>(context, listen: false).registerUserStep5(
                                              termsAndConditions: _isChecked.toString(), deviceToken: fcmToken, context: context);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          if(finalResult == AuthResult.success)
                                          {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // void closeDialogAndNavigate() {
                                                //   Navigator.of(context)
                                                //       .pop();
                                                //   // Navigator.of(context)
                                                //   //     .pushNamedAndRemoveUntil('/SigninWithEmail', (Route d) => false,
                                                //   //     arguments: {
                                                //   //       'comingFromWallet':false
                                                //   //     }
                                                //   // );
                                                // }
                                                //
                                                // Future.delayed(Duration(seconds: 2),
                                                //     closeDialogAndNavigate);
                                                return
                                                  Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  backgroundColor: Colors.transparent,
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 7, sigmaY: 7),
                                                    child: Container(
                                                      height: 73.h,
                                                      decoration: BoxDecoration(
                                                        color: themeNotifier.isDark
                                                            ? AppColors.showDialogClr
                                                            : AppColors.textColorWhite,
                                                        borderRadius:
                                                        BorderRadius.circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppColors.textColorBlack.withOpacity(0.95), // Dark shadow color
                                                            offset: Offset(0, 0), // No offset, shadow will appear equally on all sides
                                                            blurRadius: 10, // Adjust blur for softer shadow
                                                            spreadRadius: 0.4, // Spread the shadow slightly
                                                          ),
                                                        ],
                                                      ),

                                                      padding: EdgeInsets.all(16.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            height: 40.h,
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 2.sp,
                                                                  right: 2.sp,
                                                                  bottom: 15.sp,
                                                                  top: 5.sp),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: themeNotifier
                                                                        .isDark
                                                                        ? AppColors
                                                                        .whiteColorWithOpacity
                                                                        .withOpacity(0.05)
                                                                        : AppColors
                                                                        .backgroundColor
                                                                        .withOpacity(0.1),
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        15)),
                                                                child:     Align(
                                                                  alignment: Alignment.center,
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(15),
                                                                    child: Image.asset(
                                                                      "assets/images/terms_logo.png",
                                                                      fit: BoxFit.cover,
                                                                      width: double.infinity,
                                                                      // height: 13.8.h,
                                                                      // width: 13.8.h,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "Welcome to KSA’s Web3 Gateway"
                                                                .tr(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                height: 1.3,
                                                                color: themeNotifier.isDark
                                                                    ? AppColors.textColorWhite
                                                                    : AppColors
                                                                    .textColorBlack,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 17.5.sp,
                                                                fontFamily: 'Blogger Sans'),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          Text(
                                                            "This is the beginning for so much more to come!"
                                                                .tr(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                height: 1.4,
                                                                color:
                                                                AppColors.textColorGrey,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 11.7.sp,
                                                                fontFamily: 'Inter'),
                                                          ),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.end,
                                                            children: [
                                                              Image.asset(
                                                                "assets/images/twitter.png",
                                                                height: 2.h,
                                                                width: 2.h,
                                                                color: themeNotifier.isDark
                                                                    ? AppColors.textColorWhite
                                                                    : AppColors
                                                                    .textColorBlack,
                                                              ),
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Image.asset(
                                                                "assets/images/instagram.png",
                                                                height: 2.h,
                                                                width: 2.h,
                                                                color: themeNotifier.isDark
                                                                    ? AppColors.textColorWhite
                                                                    : AppColors
                                                                    .textColorBlack,
                                                              ),
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Image.asset(
                                                                "assets/images/discord.png",
                                                                height: 2.h,
                                                                width: 2.h,
                                                                color: themeNotifier.isDark
                                                                    ? AppColors.textColorWhite
                                                                    : AppColors
                                                                    .textColorBlack,
                                                              ),
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Image.asset(
                                                                "assets/images/telegram.png",
                                                                height: 2.h,
                                                                width: 2.h,
                                                                color: themeNotifier.isDark
                                                                    ? AppColors.textColorWhite
                                                                    : AppColors
                                                                    .textColorBlack,
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 2.h,),
                                                          Text(
                                                            "Support by following & interacting with a growing Community."
                                                                .tr(),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                height: 1.4,
                                                                color:
                                                                AppColors.textColorGrey,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 10.sp,
                                                                fontFamily: 'Inter'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            // }

                                          }
                                        },
                                        isGradient: true,
                                        color: Colors.transparent,
                                        textColor: AppColors.textColorBlack,
                                        // isLoading:_isLoading
                                    ),
                                    SizedBox(
                                      height:  OS.Platform.isIOS ? 2.h : 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(_isLoading)
            Positioned(
                top: 12.h,
                bottom: 0,
                left: 0,
                right: 0,
                child: LoaderBluredScreen())
        ],
      );
    });
  }
}
