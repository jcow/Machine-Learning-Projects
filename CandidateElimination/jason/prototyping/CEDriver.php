<?php 

require_once('Utils.php');
require_once('CE.php');

$d = read_csv('data/trainingDataCandElim.csv');
unset($d[0]);
//shuffle($d);

$d_classes = col($d, 6);
$d = rm_col($d, 6);


$lrange = range(0, count($d)-10, 10);
$hrange = range(10, count($d), 10);

$guesses = array();
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

	$ce = new CE($new_data, $new_classes, 'Enjoy Sport', 'Do Not Enjoy');
	$ce->run();

	for($j = 0; $j < count($classification_rows); $j++){
		$guess = $ce->classify($classification_rows[$j]);
		
		if($guess === $classification_classes[$j]){
			$correct++;
		}
	}

}



var_dump($correct);
var_dump($correct/count($d));