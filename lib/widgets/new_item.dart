import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglist_app/data/categories.dart';
import 'package:shoppinglist_app/models/category.dart';

import 'package:http/http.dart' as http;
import 'package:shoppinglist_app/models/grocery_item.dart';
class NewItem extends StatefulWidget{
const NewItem({super.key});

@override
State<NewItem> createState(){
  return _NewItemState();
}

}
class _NewItemState extends State<NewItem>{
  final _formKey=GlobalKey<FormState>();
  var _enteredName='';
  var _enteredQuantity=1;
  var _selectedCategory=categories[Categories.vegetables]!;
  var _isSending=true;
  void _saveItem() async{
if(_formKey.currentState!.validate()){
_formKey.currentState!.save();
setState(() {
  _isSending=true;
});
final url=Uri.https(
  'flutter-prep-df755-default-rtdb.asia-southeast1.firebasedatabase.app','shopping-list.json');
final respone=await http.post(url,headers: {
  'Content_Type': "application/json",
},body:json.encode({
  'name': _enteredName ,
  'quantity': _enteredQuantity,
 'category': _selectedCategory.title,
}),);
respone.body;
final resData= json.decode(respone.body);
if(!context.mounted) return;
Navigator.of(context).pop(GroceryItem(
  id:resData['name'],
name: _enteredName,
quantity: _enteredQuantity,
category: _selectedCategory));
}

  }
@override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
      title: const Text("Add a new item"),
   
    ),
    body:  Padding(
      padding: const  EdgeInsets.all(12),
      child:Form(
        key: _formKey,
        child:Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration:const InputDecoration( label:Text('Name')),
              validator:(value){
                if(value==null||value.isEmpty||value.trim().length <=1 || value.trim().length>50)
               { return 'Must be between 1 n 50 characters';}
               return null;
              } ,
              onSaved: (value){
                if(value==null){

                }
                _enteredName=value!;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    
                    decoration:  const InputDecoration(
                      label:Text('Quantity')
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredQuantity.toString(),
                     validator:(value){
                    if(value==null||value.isEmpty||
                    int.tryParse(value)==null||
                    int.tryParse(value)! <=0||
                    value.trim().length>50)
               { return 'Must be a valid positive numbers';}
               return null;},
                onSaved: (value){
                    _enteredQuantity=int.parse(value!);
                  }
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: DropdownButtonFormField(
              
                    value:_selectedCategory ,
                    items: [
                    for(final category in categories.entries) 
                      DropdownMenuItem(
                        
                      value: category.value,  
                      child: 
                      Row(children: [
                        Container(width: 16,height: 16,color:category.value.color),
                        const SizedBox(width: 6,),
                        Text(category.value.title)],))
                  ],onChanged: (value){
                    setState(() {
                        _selectedCategory=value!;
                    });
                    

                  },),
                )
              ],
            ),
            const SizedBox(height: 6,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              TextButton(onPressed:_isSending?null: (){
                _formKey.currentState!.reset();
              }, 
              child:const  Text('Reset')),
              ElevatedButton(onPressed:_isSending?null: _saveItem,
               child:_isSending?
               const SizedBox(height: 12,
               width: 16,
               child: CircularProgressIndicator(),):
               const Text("Add item"))
            ],)
          ],)
      ),),
     
   );
  }
}