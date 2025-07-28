import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/router/routes/search.dart';

class SearchSubcategoryAllTile extends StatelessWidget {
  const SearchSubcategoryAllTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchState, NewznabCategoryData?>(
      selector: (_, state) => state.activeCategory,
      builder: (context, category, _) => ZebrraBlock(
        title: 'search.AllSubcategories'.tr(),
        body: [TextSpan(text: category?.name ?? 'zebrrasea.Unknown'.tr())],
        trailing: ZebrraIconButton(
            icon: context.read<SearchState>().activeCategory?.icon,
            color: ZebrraColours().byListIndex(0)),
        onTap: () async {
          context.read<SearchState>().activeSubcategory = null;
          SearchRoutes.RESULTS.go();
        },
      ),
    );
  }
}
