import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the specific login/signup forms
import 'customer_login_form_screen.dart'; 
import 'customer_signup_form_screen.dart'; 

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the full screen height
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate the usable height by subtracting the AppBar and safe area (top padding)
    final usableHeight = screenHeight - AppBar().preferredSize.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      // --- 1. ADDED APP BAR FOR BACK BUTTON ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A), // Purple header
        iconTheme: const IconThemeData(color: Colors.white), // Ensures the back arrow is white
        automaticallyImplyLeading: true, // Ensures the back button is shown
      ),
      
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFF6A1B9A), // Deep purple background
          // Set the minimum height of the container to the usable screen height
          height: usableHeight,
          
          child: Center(
            child: Column(
              // MainAxisAlignment.center centers content vertically using the full usable height.
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: <Widget>[
                // --- My RATE Title (Padding removed, styling matched to main.dart) ---
                Column(
                  children: [
                    // "My" text
                    Text(
                      'My',
                      style: GoogleFonts.satisfy( 
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        shadows: const [ 
                          Shadow(
                            color: Color.fromARGB(76, 0, 0, 0),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    // "RATE" text (Styles exactly match main.dart)
                    Text(
                      'RATE',
                      style: GoogleFonts.poppins( 
                        color: const Color(0xFF81D4FA), // Light Blue Accent
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 0.8, // Tighter spacing to "My"
                        shadows: const [ 
                          Shadow(
                            color: Color.fromARGB(128, 0, 0, 0),
                            offset: Offset(3, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // --- VERTICAL SPACING ---
                const SizedBox(height: 120), 

                // --- CUSTOMER Role Identifier Button (Static) ---
                SizedBox(
                  width: 280,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: null, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 5,
                    ),
                    child: const Text('CUSTOMER'),
                  ),
                ),
                
                // --- VERTICAL SPACING ---
                const SizedBox(height: 60), 

                // --- SIGN UP and LOG IN Buttons (Row) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SIGN UP Button (Blue, Filled)
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigates to Sign Up Form
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerSignupFormScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5), // Blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('SIGN UP'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // LOG IN Button (White, Outlined)
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigates to Log In Form
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerLoginFormScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('LOG IN'),
                      ),
                    ),
                  ],
                ),
                
                // Pushes the tagline to the bottom
                const Spacer(), 

                // --- 5. Tagline ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                  child: Text(
                    ' "Real opinions. Honest ratings. Smarter choices." ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: const [
                        Shadow(
                          color: Color.fromARGB(76, 0, 0, 0),
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
