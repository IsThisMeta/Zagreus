import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';

class SABnzbdAppBarStats extends StatelessWidget {
  const SABnzbdAppBarStats({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Selector<SABnzbdState, Tuple5<bool, String, String, String, int>>(
        selector: (_, model) => Tuple5(
          model.paused, //item1
          model.currentSpeed, //item2
          model.queueTimeLeft, //item3
          model.queueSizeLeft, //item4
          model.speedLimit, //item5
        ),
        builder: (context, data, widget) => GestureDetector(
          onTap: () async => _onTap(context, data.item5),
          child: Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: ZebrraColours.grey,
                  fontSize: ZebrraUI.FONT_SIZE_H3,
                ),
                children: [
                  TextSpan(
                    text: _status(data.item1, data.item2),
                    style: const TextStyle(
                      fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
                      fontSize: ZebrraUI.FONT_SIZE_HEADER,
                      color: ZebrraColours.accent,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(text: data.item3 == '0:00:00' ? '―' : data.item3),
                  TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
                  TextSpan(text: data.item4 == '0.0 B' ? '―' : data.item4)
                ],
              ),
              overflow: TextOverflow.fade,
              maxLines: 2,
              softWrap: false,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      );

  String _status(bool paused, String speed) => paused
      ? 'Paused'
      : speed == '0.0 B/s'
          ? 'Idle'
          : speed;

  Future<void> _onTap(BuildContext context, int speed) async {
    HapticFeedback.lightImpact();
    List values = await SABnzbdDialogs.speedLimit(context, speed);
    if (values[0])
      switch (values[1]) {
        case -1:
          {
            values = await SABnzbdDialogs.customSpeedLimit(context);
            if (values[0])
              SABnzbdAPI.from(ZebrraProfile.current)
                  .setSpeedLimit(values[1])
                  .then((_) => showZebrraSuccessSnackBar(
                        title: 'Speed Limit Set',
                        message: 'Set to ${values[1]}%',
                      ))
                  .catchError((error) => showZebrraErrorSnackBar(
                        title: 'Failed to Set Speed Limit',
                        error: error,
                      ));
            break;
          }
        default:
          SABnzbdAPI.from(ZebrraProfile.current)
              .setSpeedLimit(values[1])
              .then((_) => showZebrraSuccessSnackBar(
                    title: 'Speed Limit Set',
                    message: 'Set to ${values[1]}%',
                  ))
              .catchError((error) => showZebrraErrorSnackBar(
                    title: 'Failed to Set Speed Limit',
                    error: error,
                  ));
      }
  }
}
