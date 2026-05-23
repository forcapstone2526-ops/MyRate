// import 'package:cached_network_image/cached_network_image.dart';
//import 'package:flutter/material.dart';

//const String kBgImageUrl =
   // 'https://bftmwciweamdcyrkagvn.supabase.co/storage/v1/object/public/backgrounds/uls_image.jpg';

//class BackgroundScaffold extends StatelessWidget {
  //final PreferredSizeWidget? appBar;
  //final Widget body;
  //final Widget? bottomNavigationBar;
  //final Widget? endDrawer;
  //final GlobalKey<ScaffoldState>? scaffoldKey;
  //final bool extendBodyBehindAppBar;

  //const BackgroundScaffold({
    //super.key,
    //this.appBar,
    //required this.body,
    //this.bottomNavigationBar,
    //this.endDrawer,
    //this.scaffoldKey,
    //this.extendBodyBehindAppBar = false,
 // });

  //@override
  //Widget build(BuildContext context) {
   // return Scaffold(
//      key: scaffoldKey,
  //    backgroundColor: const Color(0xFF6A1B9A), // ✅ purple fallback, no asset needed
    //  extendBodyBehindAppBar: extendBodyBehindAppBar,
      //appBar: appBar,
     // endDrawer: endDrawer,
     // bottomNavigationBar: bottomNavigationBar,
   //   body: Stack(
    //    children: [
          // ✅ Cached background
      //    Positioned.fill(
      //      child: CachedNetworkImage(
      //        imageUrl: kBgImageUrl,
      //        fit: BoxFit.cover,
      //        fadeInDuration: Duration.zero,
      //        fadeOutDuration: Duration.zero,
      //        // ✅ No asset fallback — just show purple color (from scaffold bg)
        //      errorWidget: (context, url, error) => const ColoredBox(
        //        color: Color(0xFF6A1B9A),
        //      ),
         //   ),
         // ),

          // ✅ White overlay
        //  Positioned.fill(
          //  child: Container(
            //  color: Colors.white.withOpacity(0.75),
        //    ),
         // ),

          // ✅ Page content
          //body,
//        ],
  //    ),
    //);
 // }
//}