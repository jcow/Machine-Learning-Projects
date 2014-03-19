<?php


require_once('Utils.php');

class CEDos{

	private $data;
	private $classes;

	public function __construct($data, $classes, $pos, $neg){
		$this->data = $data;
		$this->classes = $classes;
		$this->pos = $pos;
		$this->neg = $neg;
	}

	public function run(){
		$data_keys = array_keys($this->data);
		$attr_size = count($this->data[$data_keys[0]]);

		$s = array_fill(0, $attr_size, '?');

		$counts = array_fill(0, $attr_size, array());
		
		foreach($this->data as $row_index=>$row){
			for($i = 0; $i < $attr_size; $i++){
				if(!array_key_exists($row[$i], $counts[$i])){
					$counts[$i][$row[$i]][$this->pos] = 0;
					$counts[$i][$row[$i]][$this->neg] = 0;
				}

				$counts[$i][$row[$i]][$this->classes[$row_index]]++;
			}
		}

		var_dump($counts);
	}

}


$data = array(
	array('sunny', 'warm', 'normal', 'strong', 'warm', 'same'),
	array('sunny', 'warm', 'high', 'strong', 'warm', 'same'),
	array('rainy', 'cold', 'high', 'strong', 'warm', 'change'),
	array('sunny', 'warm', 'high', 'strong', 'cool', 'change')
);

$classes = array('yes', 'yes', 'no', 'yes');


$c = new CEDos($data, $classes, 'yes', 'no');
$c->run();


// $d = read_csv('data/trainingDataCandElim.csv');
// unset($d[0]);
// $d_classes = col($d, 6);
// $d = rm_col($d, 6);

// $c = new CEDos($d, $d_classes, 'Enjoy Sport', 'Do Not Enjoy');
// $c->run();