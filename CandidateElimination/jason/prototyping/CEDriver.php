<?php 

require_once('Utils.php');
require_once('CE.php');

$d = read_csv('data/trainingDataCandElim.csv');
unset($d[0]);
shuffle($d);

$d_classes = col($d, 6);
$d = rm_col($d, 6);


$lrange = range(0, count($d)-10, 10);
$hrange = range(10, count($d), 10);

// $d = range(1, 100, 1);
// $d_classes = range(1, 100, 1);

$correct = 0;
for($i = 0; $i < count($lrange); $i++){
	$low = $lrange[$i];
	$amount = 10;

	$new_data = $d;
	$new_classes = $d_classes;

	array_splice($new_data, $low, $amount);
	array_splice($new_classes, $low, $amount);

	$classification_rows = array_slice($d, $low, $amount);
	$classification_classes = array_slice($d_classes, $low, $amount);

	// var_dump(count($classification_rows));
	// var_dump(count($classification_classes));
	// var_dump(count($new_data));
	// var_dump(count($new_classes));
	// var_dump('----');

	$ce = new CE($new_data, $new_classes, 'Enjoy Sport', 'Do Not Enjoy');
	$ce->run();

	for($j = 0; $j < count($classification_rows); $j++){
		$guess = $ce->classify($classification_rows[$j]);
		
		if($guess === $classification_classes[$j]){
			$correct++;
		}
	}

}

// 	


// leave one out
// $correct = 0;
// for($i = 1; $i < count($d); $i++){
// 	$new_data = $d;
// 	$new_classes = $d_classes;

// 	$classification_row = $new_data[$i];
// 	$classification_class = $new_classes[$i];

// 	unset($new_data[$i]);
// 	unset($new_classes[$i]);

// 	$ce = new CE($new_data, $new_classes, 'Enjoy Sport', 'Do Not Enjoy');
// 	$ce->run();

// 	$guess = $ce->classify($classification_row);
// 	if($guess === $classification_class){
// 		$correct++;
// 	}
// }


var_dump($correct);
var_dump($correct/count($d));