import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:solve_student/authentication/pages/register_page.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/widgets/dialogs.dart';

import '../../feature/calendar/constants/assets_manager.dart';
import '../../feature/calendar/constants/custom_colors.dart';
import '../../feature/calendar/constants/custom_styles.dart';
import '../../feature/calendar/widgets/sizebox.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;

  _handleGoogleBtnClick() async {
    try {
      // Dialogs.showProgressBar(context);
      var user = await _signInWithGoogle();
      if (user != null) {
        // log('\nUser: ${user.user}');
        // log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if (await authProvider!.userExists(user.user!)) {
        } else {
          await authProvider!.createUser(
            id: user.user?.uid ?? "",
            name: user.user?.displayName ?? "",
            email: user.user?.email ?? "",
            image: user.user?.photoURL ?? "",
          );
        }
        authProvider!.getSelfInfo();
        // var route =
        //     MaterialPageRoute(builder: (context) => const Authenticate());
        // Navigator.pushReplacement(context, route);
      }
    } catch (e) {
      Dialogs.showSnackbar(context, 'Login failed');
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    // Optional reachability check – remove if you don’t want it.
    try {
      await InternetAddress.lookup('google.com');
    } catch (_) {
      return null;
    }

    final GoogleSignIn g = GoogleSignIn.instance;

    try {
      // 1️⃣ Show the Google-account picker (new 7.x API).
      //    authenticate() throws if the user taps “Cancel”.
      final GoogleSignInAccount account =
      await g.authenticate(scopeHint: const ['email']);

      // 2️⃣ Tokens are now synchronous.
      final GoogleSignInAuthentication authData = account.authentication;

      // 3️⃣ Build a Firebase credential *with the ID token only*.
      final credential = GoogleAuthProvider.credential(
        idToken: authData.idToken,
      );

      // 4️⃣ Sign in to Firebase & return the result.
      return FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // User cancelled or another G-Sign-In error.
      // log('Google sign-in error: ${e.code.name} – ${e.description}');
      return null;
    } catch (e) {
      // Anything else (network, Firebase).
      // log('Unexpected sign-in error: $e');
      return null;
    }
  }

  _handleAppleBtnClick() async {
    try {
      var auth = await _signInWithApple();
      if (auth!.user != null) {
        dev.log('\nUser: ${auth.user}');
        if (await authProvider!.userExists(auth.user!)) {
        } else {
          await authProvider!.createUser(
            id: auth.user!.uid,
            name: auth.user!.displayName ?? "Apple User",
            email: auth.user!.email ?? "",
          );
        }
        authProvider!.getSelfInfo();
      }
    } on FirebaseAuthException catch (e) {
      dev.log('FirebaseAuthException: ${e.code} – ${e.message}');
      Dialogs.showSnackbar(context, 'Login failed');
    } on SignInWithAppleAuthorizationException catch (e) {
      dev.log('Apple auth error: ${e.code} – ${e.message}');
      Dialogs.showSnackbar(context, 'Login failed');
    }
  }

  Future<UserCredential?> _signInWithApple() async {
    final app = Firebase.app();
    final o = app.options;
    dev.log('FB projectId=${o.projectId} appId=${o.appId} iosBundleId=${o.iosBundleId}');

    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: hashedNonce,
    );
    dev.log('Apple idToken present? ${appleCredential.identityToken != null}');
    final payload = _decodeJwt(appleCredential.identityToken!);
    dev.log('Apple JWT aud=${payload["aud"]} iss=${payload["iss"]}');
    dev.log('Apple JWT nonce claim=${payload["nonce"]}');
    dev.log('Hashed we sent     =$hashedNonce');
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    return userCredential;
  }

  Future<void> signInWithEmail(BuildContext context, String email, String password) async {
    await authProvider!.signInWithEmailAndPassword(email.trim(), password);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in')));
      Navigator.of(context).pop(); // or go to home
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> _decodeJwt(String jwt) {
    final parts = jwt.split('.');
    String _decode(String str) {
      str = str.replaceAll('-', '+').replaceAll('_', '/');
      switch (str.length % 4) {
        case 2: str += '=='; break;
        case 3: str += '='; break;
      }
      return utf8.decode(base64.decode(str));
    }
    return json.decode(_decode(parts[1])) as Map<String, dynamic>;
  }

  AuthProvider? authProvider;
  bool _obscured = false;
  final textFieldFocusNode = FocusNode();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus)
        return; // If focus is on text field, don't unfocused
      textFieldFocusNode.canRequestFocus =
          false; // Prevents focus if tap on eye
    });
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('เข้าสู่ระบบ', style: CustomStyles.bold22Black363636),
                  S.h(8.00),
                  Text("เสริมสร้างทักษะ และความรู้ผ่านคอร์สเรียนคุณภาพของเรา",
                      style: CustomStyles.med14Black363636),
                  Text("เข้าถึงเนื้อหาบทเรียนและเทคนิคต่าง ๆ จากติวเตอร์",
                      style: CustomStyles.med14Black363636),
                  S.h(45.0),
                  Image.asset(
                    'assets/images/touch_video.png',
                    width: 165,
                    height: 165,
                  ),
                  S.h(46.0),
                  Text('เข้าสู่ระบบด้วยบัญชี',
                      style: CustomStyles.med18Black363636),
                  S.h(36.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Login with Google
                      InkWell(
                        onTap: () {
                          _handleGoogleBtnClick();
                        },
                        child: Container(
                          width: 200.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: CustomColors.grayF3F3F3,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/ic_google.png',
                                width: 23.4,
                                height: 24,
                              ),
                              S.w(16.0),
                              Text("Google",
                                  style: CustomStyles.med14Black363636)
                            ],
                          ),
                        ),
                      ),
                      S.h(16.0),
                      // Login with Apple ID
                      Platform.isIOS
                          ? InkWell(
                              onTap: () {
                                _handleAppleBtnClick();
                              },
                              child: Container(
                                width: 200.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: CustomColors.grayF3F3F3,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageAssets.icApple,
                                      width: 19.56,
                                      height: 24,
                                    ),
                                    S.w(16.0),
                                    Text("Apple ID",
                                        style: CustomStyles.med14Black363636)
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  S.h(32.0),
                  // ---- Divider ----
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1.0)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'หรือ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---- Email ----
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'อีเมล์',
                      prefixIcon: const Icon(Icons.mail_outline),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- Password ----
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---- Sign in button ----
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => signInWithEmail(context, _emailCtrl.text, _passCtrl.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.greenPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      child: const Text('ลงชื่อเข้าใช้',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(thickness: 1.0),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'หากคุณเข้าใช้ Solve ครั้งแรก ?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          style: TextButton.styleFrom(foregroundColor: CustomColors.greenPrimary),
                          child: const Text('สร้างบัญชี'),
                        ),
                      ),
                    ],
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Container(
                  //       height: 1,
                  //       width: _util.isTablet() ? 161 : 132,
                  //       color: CustomColors.grayF3F3F3,
                  //     ),
                  // S.w(8.0),
                  // Text("หรือ", style: CustomStyles.med18Black363636),
                  // S.w(8.0),
                  // Container(
                  //   height: 1,
                  //   width: _util.isTablet() ? 161 : 132,
                  //   color: CustomColors.grayF3F3F3,
                  // )
                  //   ],
                  // ),
                  // S.h(32.0),
                  //
                  // /// Form For Email
                  // SizedBox(
                  //   height: 40,
                  //   width: 368,
                  //   child: TextFormField(
                  //     controller: email,
                  //     style: CustomStyles.med14Black363636,
                  //     decoration: InputDecoration(
                  //         labelText: 'อีเมล',
                  //         labelStyle: CustomStyles.med14Black363636,
                  //         prefixIcon: const Icon(Icons.mail),
                  //         enabledBorder: const OutlineInputBorder(
                  //           // width: 0.0 produces a thin "hairline" border
                  //           borderSide: BorderSide(
                  //               color: CustomColors.grayE5E6E9, width: 1),
                  //         ),
                  //         border: const OutlineInputBorder()),
                  //   ),
                  // ),
                  // S.h(16.0),
                  //
                  // /// Form For Password
                  // SizedBox(
                  //   height: 40,
                  //   width: 368,
                  //   child: TextFormField(
                  //     style: CustomStyles.med14Black363636,
                  //     obscureText: _obscured,
                  //     focusNode: textFieldFocusNode,
                  //     keyboardType: TextInputType.visiblePassword,
                  //     controller: password,
                  //     decoration: InputDecoration(
                  //       labelText: 'รหัสผ่าน',
                  //       labelStyle: CustomStyles.med14Black363636,
                  //       prefixIcon: const Icon(Icons.lock),
                  //       enabledBorder: const OutlineInputBorder(
                  //         // width: 0.0 produces a thin "hairline" border
                  //         borderSide: BorderSide(
                  //             color: CustomColors.grayE5E6E9, width: 1),
                  //       ),
                  //       border: const OutlineInputBorder(),
                  //       suffixIcon: Padding(
                  //         padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  //         child: GestureDetector(
                  //           onTap: _toggleObscured,
                  //           child: Icon(
                  //             _obscured
                  //                 ? Icons.visibility_rounded
                  //                 : Icons.visibility_off_rounded,
                  //             size: 24,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // S.h(32.0),
                  // GestureDetector(
                  //   // onTap: () => Navigator.push(
                  //   //   context,
                  //   //   MaterialPageRoute(
                  //   //       builder: (context) => const ForgotPasswordPage()),
                  //   // ),
                  //   child: Text("ลืมรหัสผ่าน",
                  //       style: CustomStyles.med16GreenUnderline),
                  // ),
                  // S.h(32.0),
                  // InkWell(
                  //   onTap: () {
                  //     // if (email.text == 'tutor') {
                  //     //   Navigator.push(
                  //     //     context,
                  //     //     MaterialPageRoute(
                  //     //         builder: (context) => const MainTabPage()),
                  //     //   );
                  //     // } else {
                  //     //   Navigator.push(
                  //     //     context,
                  //     //     MaterialPageRoute(
                  //     //         builder: (context) =>
                  //     //             const OnBoardingSettingPage()),
                  //     //   );
                  //     // }
                  //   },
                  //   child: Container(
                  //     width: 174.0,
                  //     height: 40.0,
                  //     decoration: BoxDecoration(
                  //       color: CustomColors.greenPrimary,
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //     child: Center(
                  //       child: Text('ลงชื่อเข้าใช้',
                  //           style: CustomStyles.med14White),
                  //     ),
                  //   ),
                  // ),
                  // S.h(32.0),
                  // Container(
                  //   height: 1,
                  //   width: 368,
                  //   color: CustomColors.grayF3F3F3,
                  // ),
                  // S.h(40.0),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text("หากคุณเข้าใช้  Solve ครั้งแรก?",
                  //         style: CustomStyles.bold16Black363636),
                  //     S.w(16.0),
                  //     GestureDetector(
                  //       // onTap: () => Navigator.push(
                  //       //   context,
                  //       //   MaterialPageRoute(
                  //       //       builder: (context) =>
                  //       //           const CreateAccountPage()),
                  //       // ),
                  //       child: Text("สร้างบัญชี",
                  //           style: CustomStyles.med16GreenUnderline),
                  //     ),
                  //   ],
                  // ),
                  // S.h(24.0),
                ],
              ),
            ),
          )),
    );
  }

  // Widget _buildFormWidget() {
  //   return AutofillGroup(
  //     child: Column(
  //       children: [
  //         AppTextField(
  //           textFieldType: TextFieldType.EMAIL,
  //           controller: _email,
  //           // focus: emailFocus,
  //           // nextFocus: passwordFocus,
  //           // errorThisFieldRequired: language.requiredText,
  //           decoration: inputDecoration(context, labelText: "Email"),
  //           // suffix: ic_message.iconImage(size: 10).paddingAll(14),
  //           autoFillHints: [AutofillHints.email],
  //         ),
  //         16.height,
  //         AppTextField(
  //           textFieldType: TextFieldType.PASSWORD,
  //           controller: _password,
  //           // focus: passwordFocus,
  //           // suffixPasswordVisibleWidget:
  //           //     ic_show.iconImage(size: 10).paddingAll(14),
  //           // suffixPasswordInvisibleWidget:
  //           //     ic_hide.iconImage(size: 10).paddingAll(14),
  //           decoration: inputDecoration(context, labelText: "Password"),
  //           autoFillHints: [AutofillHints.password],
  //           onFieldSubmitted: (s) {
  //             // loginUsers();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildRememberWidget() {
  //   return Column(
  //     children: [
  //       8.height,
  //       // Row(
  //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       //   children: [
  //       //     RoundedCheckBox(
  //       //       borderColor: context.primaryColor,
  //       //       checkedColor: context.primaryColor,
  //       //       // isChecked: isRemember,
  //       //       text: "Remember Me",
  //       //       textStyle: secondaryTextStyle(),
  //       //       size: 20,
  //       //       onTap: (value) async {
  //       //         // await setValue(IS_REMEMBERED, isRemember);
  //       //         // isRemember = !isRemember;
  //       //         // setState(() {});
  //       //       },
  //       //     ),
  //       //     TextButton(
  //       //       onPressed: () {
  //       //         // showInDialog(
  //       //         //   context,
  //       //         //   contentPadding: EdgeInsets.zero,
  //       //         //   dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
  //       //         //   builder: (_) => ForgotPasswordScreen(),
  //       //         // );
  //       //       },
  //       //       child: Text(
  //       //         "Forgot Password",
  //       //         style: boldTextStyle(
  //       //             color: ColorConstants.primaryColor,
  //       //             fontStyle: FontStyle.italic),
  //       //         textAlign: TextAlign.right,
  //       //       ),
  //       //     ).flexible(),
  //       //   ],
  //       // ),
  //       24.height,
  //       AppButton(
  //         text: "Sign In",
  //         color: ColorConstants.primaryColor,
  //         textColor: Colors.white,
  //         width: context.width() - context.navigationBarHeight,
  //         onTap: () {
  //           // loginUsers();
  //           authprovider!.logIn(_email.text, _password.text).then(
  //             (user) {
  //               if (user != null) {
  //                 Navigator.pushReplacement(context,
  //                     MaterialPageRoute(builder: (context) => Authenticate()));
  //                 print("Account Created Sucessfull");
  //               } else {
  //                 print("Login Failed");
  //               }
  //             },
  //           );
  //         },
  //       ),
  //       16.height,
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text("Don't have an account?", style: secondaryTextStyle()),
  //           TextButton(
  //             onPressed: () {
  //               // hideKeyboard(context);
  //               // SignUpScreen().launch(context);
  //               var route =
  //                   MaterialPageRoute(builder: (context) => RegisterPage());
  //               Navigator.push(context, route);
  //             },
  //             child: Text(
  //               "Sign Up",
  //               style: boldTextStyle(
  //                 color: ColorConstants.primaryColor,
  //                 decoration: TextDecoration.underline,
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}
