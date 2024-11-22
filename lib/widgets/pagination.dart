import 'package:flutter/material.dart';
import 'package:hesa_wallet/constants/colors.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BeerListView extends StatefulWidget {
  @override
  _BeerListViewState createState() => _BeerListViewState();
}

class _BeerListViewState extends State<BeerListView> {
  static const _pageSize = 10;

  // Initialize the PagingController with the first page key.
  final PagingController<int, BeerSummary> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();

    // Set up a listener for page requests.
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch data from the API.
      final newItems = await RemoteApi.getBeerList(pageKey, _pageSize);

      // Determine if it's the last page.
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        // Append the last page if no more data is available.
        _pagingController.appendLastPage(newItems);
      } else {
        // Calculate the next page key and append the current page.
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      // Handle errors and notify the controller.
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beer List'),
      ),
      body: PagedListView<int, BeerSummary>(
        // Connect the PagingController.
        pagingController: _pagingController,

        // Use the builderDelegate to define how each item should look.
        builderDelegate: PagedChildBuilderDelegate<BeerSummary>(
          itemBuilder: (context, item, index) => BeerListItem(
            beer: item,
          ),
          // Optional: Customize loading and error widgets.
          firstPageProgressIndicatorBuilder: (context) => Center(
            child: CircularProgressIndicator(
              color: AppColors.hexaGreen,
            ),
          ),
          newPageProgressIndicatorBuilder: (context) => Center(
            child: CircularProgressIndicator(
              color: AppColors.hexaGreen,
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Text('No beers found'),
          ),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Text('Error loading beers'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the PagingController to free up resources.
    _pagingController.dispose();
    super.dispose();
  }
}

// Mock classes to represent API and data models.
class RemoteApi {
  static Future<List<BeerSummary>> getBeerList(int pageKey, int pageSize) async {
    // Simulate an API call and return dummy data.
    await Future.delayed(Duration(seconds: 1));
    if (pageKey < 3 * pageSize) {
      return List.generate(pageSize, (index) => BeerSummary(name: 'Beer ${pageKey + index + 1}'));
    } else {
      return [];
    }
  }
}

class BeerSummary {
  final String name;

  BeerSummary({required this.name});
}

class BeerListItem extends StatelessWidget {
  final BeerSummary beer;

  const BeerListItem({Key? key, required this.beer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(beer.name),
    );
  }
}
