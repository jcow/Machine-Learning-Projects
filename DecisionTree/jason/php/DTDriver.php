<?php

require_once('DT.php');

$raw_data = read_csv('data/train.csv');
$column_names = $raw_data[0];
unset($column_names[9]);
unset($raw_data[0]);
$target = col($raw_data, 9);
$predictors = rm_col($raw_data, 9);
$potential_values = array_fill(0, 9, array('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'));

$raw_test_data = read_csv('data/test.csv');
$column_test_names = $raw_test_data[0];
unset($column_test_names[9]);
unset($raw_test_data[0]);
$test_classes = col($raw_test_data, 9);
$test_column_avgs = array_pop($raw_test_data);
$test_data = rm_col($raw_test_data, 9);

foreach($test_data as $r_key=>$row){
	foreach($row as $c_key=>$value){
		if($value === '0'){
			$test_data[$r_key][$c_key] = $test_column_avgs[$c_key];
		}
	}
}


$dt = new DT();
$dt->setData($predictors)
->setClasses($target)
->setPotentialValues($potential_values)
->setColumnNames($column_names);
$dt->build();

$correct = 0;
foreach($test_data as $key=>$value){
	$guess = (string)$dt->classify($value);

	if($guess === $test_classes[$key]){
		$correct++;
	}
}
$accuracy = $correct/count($test_data);
echo "Accuracy: $accuracy".PHP_EOL;
