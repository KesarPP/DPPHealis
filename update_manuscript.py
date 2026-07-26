import sys

with open('lib/screens/manuscript_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update background image
content = content.replace("'assets/images/session_timeline/manuscript_bg.jpg'", "'assets/images/session_timeline/manuscript_bg_new.png'")

# 2. Add Transform and update padding for open book
open_book_old = '''          // 2. The Book Container (Open Manuscript State) sitting cleanly on the scholar's desk
          SafeArea(
            child: AnimatedBuilder('''

open_book_new = '''          // 2. The Book Container (Open Manuscript State) sitting cleanly on the scholar's desk
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(-0.15),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25,
                  bottom: MediaQuery.of(context).size.height * 0.12,
                  left: MediaQuery.of(context).size.width * 0.08,
                  right: MediaQuery.of(context).size.width * 0.08,
                ),
                child: AnimatedBuilder('''

content = content.replace(open_book_old, open_book_new)

# Add closing bracket for the first Transform and Padding
close_open_book_old = '''                            ],
                          );
                        },
                      ),
                    ],
                ),
              ),
            ),
          ),

          // 3. 3D Swinging Book Cover Overlay and bottom unlock button sitting right on the desk bg image'''

close_open_book_new = '''                            ],
                          );
                        },
                      ),
                    ],
                ),
              ),
            ),
            ), // padding
            ), // transform
          ),

          // 3. 3D Swinging Book Cover Overlay and bottom unlock button sitting right on the desk bg image'''

content = content.replace(close_open_book_old, close_open_book_new)

# 3. Add Transform and update padding for closed book cover
closed_book_old = '''                  Expanded(
                    child: AnimatedBuilder('''

closed_book_new = '''                  Expanded(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateX(-0.15),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.25,
                          bottom: 20,
                          left: MediaQuery.of(context).size.width * 0.08,
                          right: MediaQuery.of(context).size.width * 0.08,
                        ),
                        child: AnimatedBuilder('''

content = content.replace(closed_book_old, closed_book_new)

# Add closing bracket for the second Transform and Padding
close_closed_book_old = '''                            ],
                          );
                        },
                      ),
                    ),
                    // Tap to unlock button adapted to the vintage gold/leather scroll theme'''

close_closed_book_new = '''                            ],
                          );
                        },
                      ),
                      ),
                      ),
                    ),
                    // Tap to unlock button adapted to the vintage gold/leather scroll theme'''

content = content.replace(close_closed_book_old, close_closed_book_new)

# 4. Replace the button styling
button_old = '''                    if (!_isBookOpen && !_isOpening)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: _openBook,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFDE4F2), Color(0xFFF8BBD0)], // Pastel pink gradient
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFD81B60), // Darker pink icon
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'TAP TO OPEN',
                                    style: TextStyle(
                                      color: Color(0xFFC2185B), // Dark pastel pink text
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),'''

button_new = '''                    if (!_isBookOpen && !_isOpening)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: MediaQuery.of(context).size.height * 0.12,
                        ),
                        child: GestureDetector(
                          onTap: _openBook,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFBB8D0), Color(0xFFF07BA8)], // Soft pink gradient
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'OPEN MY JOURNAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),'''

content = content.replace(button_old, button_new)

if button_new not in content or open_book_new not in content or closed_book_new not in content:
    print('Failed to replace some blocks')
    sys.exit(1)

with open('lib/screens/manuscript_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Replaced successfully')
