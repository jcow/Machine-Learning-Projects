<?php 

require_once('Utils.php');
require_once('CE.php');
require_once('Confusion.php');


function foo($values){
	for($i = 0; $i < count($values); $i++){
		print($values[$i]);
		if($i != count($values)-1){
			print(",");
		}
	}

}

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
$total_confusion = new Confusion($potential_values);
$confusions = array();
for($i = 0; $i < count($lrange); $i++){
	$iterations_correct = 0;
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
			$iterations_correct++;
		}

		$c->add($guess, $classification_classes[$j]);
		$total_confusion->add($guess, $classification_classes[$j]);
	}
	$c->setAccuracy($iterations_correct/$bin_sizes);
	$confusions[] = $c;
	$correct += $iterations_correct;
}



$counter = 1;
foreach($confusions as $c){
	print("--------------------------------------------------------------------------\n");
	print("Iteration $counter \n");
	p($c->getMatrix(), $c->getAccuracy());
	$counter++;
	print("\n");
}

print("\n\n");
print("--------------------------------------------------------------------------\n");
print("Totals \n");
$total_confusion->setAccuracy($correct/count($d));
p($total_confusion->getMatrix(), $total_confusion->getAccuracy());
print("\n\n");

// print("--------------------------------------------------------------------------\n");
// print("Totals \n");
// print("Correct Number: ".$correct."\n");
// print("Correct Percentage: ".$correct/count($d)."\n");