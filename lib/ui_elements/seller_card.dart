import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SellerCard extends StatelessWidget {
  int? id;
  String? image;
  String shopSlug;
  String? name;
  double? stars;

  SellerCard(
      {Key? key,
      this.id,
      this.image,
      this.name,
      this.stars,
      required this.shopSlug})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SellerDetails(
            slug: shopSlug,
          );
        }));
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(top: 16),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: image!,
                        fit: BoxFit.scaleDown,
                      ))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width*0.4,
                          child: Text(
                           name!,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_font_grey,
                                fontSize: 13,
                                height: 1.6,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 15,
                            child: RatingBar(
                                ignoreGestures: true,
                                initialRating: stars!,
                                maxRating: 5,
                                direction: Axis.horizontal,
                                itemSize: 15.0,
                                itemCount: 5,
                                ratingWidget: RatingWidget(
                                  full: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  half: Icon(Icons.star_half),
                                  empty: Icon(Icons.star,
                                      color: Color.fromRGBO(224, 224, 225, 1)),
                                ),
                                onRatingUpdate: (newValue) {}),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
             Icon(Icons.arrow_circle_right)
            ]),
      ),
    );
  }
}
