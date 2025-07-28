import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/search.dart';
import 'package:zebrrasea/router/routes/search.dart';

class SearchSubcategoryTile extends StatelessWidget {
  final int index;

  const SearchSubcategoryTile({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchState, NewznabCategoryData?>(
      selector: (_, state) => state.activeCategory,
      builder: (context, category, _) {
        NewznabSubcategoryData subcategory = category!.subcategories[index];
        return ZebrraBlock(
          title: subcategory.name ?? 'zebrrasea.Unknown'.tr(),
          body: [
            TextSpan(
              text: [
                category.name ?? 'zebrrasea.Unknown'.tr(),
                subcategory.name ?? 'zebrrasea.Unknown'.tr(),
              ].join(' > '),
            )
          ],
          trailing: ZebrraIconButton(
            icon: category.icon,
            color: ZebrraColours().byListIndex(index + 1),
          ),
          onTap: () async {
            context.read<SearchState>().activeSubcategory = subcategory;
            SearchRoutes.RESULTS.go();
          },
        );
      },
    );
  }
}
