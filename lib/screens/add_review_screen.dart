import 'package:bizreview/models/business_model.dart';
import 'package:bizreview/provider/bizprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatefulWidget {
  final BusinessModel business;
  const AddReviewScreen({super.key, required this.business});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  //double selectedRating = 0.0;
  @override
  Widget build(BuildContext context) {
    final addReviewProvider = Provider.of<Bizprovider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Add Review"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: addReviewProvider.addReviewformKey,
            child: Center(
              child: Column(
                children: [
                  TextFormField(
                    controller: addReviewProvider.commentController,
                    maxLines: 7,
                    minLines: 5,
                    maxLength: 300,
                    decoration: InputDecoration(
                      labelText: "Comments / Feedback",
                      alignLabelWithHint: true,
                      hintText:
                          "Write about your experience or business details...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter comments"
                        : null,
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          addReviewProvider.selectedRatingValue(index);
                        },
                        icon: Icon(
                          index < addReviewProvider.selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: addReviewProvider.isAddingReview
                        ? null
                        : () {
                            addReviewProvider.submitReview(
                              widget.business.id,
                              context,
                            );
                          },
                    child: addReviewProvider.isAddingReview
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Submitting..."),
                            ],
                          )
                        : Text("Submit Review"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
