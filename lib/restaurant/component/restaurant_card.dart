import 'package:flutter/material.dart';
import 'package:riverpod_example1/common/const/colors.dart';
import 'package:riverpod_example1/restaurant/model/restaurant_detail_model.dart';

import '../model/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  // 이미지
  final Widget image;

  // 레스토랑 이름
  final String name;

  // 레스토랑 태그
  final List<String> tags;

  // 평점 갯수
  final int ratingsCount;

  // 배송걸리는 시간
  final int deliveryTime;

  // 배송 비용
  final int deliveryFee;

  // 평균 평점
  final double ratings;

  // 상세 카드 여부
  final bool isDetail;

  // 히어로 위젯 태그
  final String? heroKey;

  final String? detail;

  const RestaurantCard({
    super.key,
    required this.image,
    required this.name,
    required this.tags,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.ratings,
    this.isDetail = false,
    this.heroKey,
    this.detail,
  });

  factory RestaurantCard.fromModel({
    required RestaurantModel model,
    bool isDetail = false,
  }) {
    return RestaurantCard(
      image: Image.network(
        model.thumbUrl,
        fit: BoxFit.cover,
      ),
      heroKey: model.id,
      // image: Image.asset('asset/img/food/ddeok_bok_gi.jpg',
      //     fit: BoxFit.cover),
      name: model.name,
      tags: model.tags,
      ratingsCount: model.ratingsCount,
      deliveryTime: model.deliveryTime,
      deliveryFee: model.deliveryFee,
      ratings: model.ratings,
      isDetail: isDetail,
      detail: model is RestaurantDetailModel ? model.detail : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (heroKey != null)
          Hero(
            tag: ObjectKey(heroKey),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
              child: image,
            ),
          ),
        if (heroKey == null)
          ClipRRect(
            borderRadius: BorderRadius.circular(isDetail ? 0 : 12.0),
            child: image,
          ),
        SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDetail ? 16.0 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                tags.join(' · '),
                style: TextStyle(
                  color: BODY_TEXT_COLOR,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _IconText(
                    icon: Icons.star,
                    lable: ratings.toString(),
                  ),
                  rederDot(),
                  _IconText(
                    icon: Icons.receipt,
                    lable: ratingsCount.toString(),
                  ),
                  rederDot(),
                  _IconText(
                    icon: Icons.timelapse_outlined,
                    lable: '$deliveryTime 분',
                  ),
                  rederDot(),
                  _IconText(
                    icon: Icons.monetization_on,
                    lable:
                        '${deliveryFee == 0 ? '무료' : deliveryFee.toString()}',
                  ),
                ],
              ),
              if (detail != null && isDetail == true)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(detail!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  rederDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        '·',
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String lable;

  const _IconText({
    required this.icon,
    required this.lable,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: PRIMARY_COLOR,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          lable,
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
