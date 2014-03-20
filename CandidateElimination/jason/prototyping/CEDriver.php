<?php 

require_once('Utils.php');
require_once('CE.php');
require_once('Confusion.php');

$d = read_csv('data/trainingDataCandElim.csv');
unset($d[0]);
shuffle($d);

$d_classes = col($d, 6);
$d = rm_col($d, 6);

$bin_sizes = count($d)/10;
$lrange = range(0, count($d)-$bin_sizes, $bin_sizes);



$potential_values = array_merge(array_unique($d_classes), array('undefined'));


$guesses = array();
$correct = 0;
$confusions = array();
for($i = 0; $i < count($lrange); $i++){
	$low = $lrange[$i];

	$new_data = $d;
	$new_classes = $d_classes;

	array_splice($new_data, $low, $bin_sizes);
	array_splice($new_classes, $low, $bin_sizes);

	$classification_rows = array_slice($d, $low, $bin_sizes);
	$classification_classes = array_slice($d_classes, $low, $bin_sizes);

	$ce = new CE($new_data, $new_classes, 'Enjoy Sport', 'Do Not Enjoy');
	$ce->run();

	$c = new Confusion($potential_values);

	for($j = 0; $j < count($classification_rows); $j++){
		$guess = $ce->classify($classification_rows[$j]);

		if($guess === $classification_classes[$j]){
			$correct++;
		}

		$c->add($guess, $classification_classes[$j]);
	}

	$confusions[] = $c;
}

function p($matrix){
	foreach($matrix as $k1=>$v1){
		foreach($v1 as $k2=>$v2){

		}
	}
}

foreach($confusions as $c){
	p($c);
	//$c->getMatrix();
}



var_dump($correct);
var_dump($correct/count($d));