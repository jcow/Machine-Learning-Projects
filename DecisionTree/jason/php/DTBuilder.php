<?php

require_once('Utils.php');

class DTBuilder{

	public function __construct(){}

	public static function build($attributes, $classes, $potential_values, $column_names){

		list($mx_value, $mx_column) = self::maxInformationGain($attributes, $classes);
		
		if($mx_column !== false){			

			$node = new DTNode();
			$node->setColumnIndex($mx_column);
			$node->setColumnName($column_names[$mx_column]);

			$counts = self::attributeCountsWithClasses(col($attributes, $mx_column), $classes);

			// go through each potential value and make a node
			foreach($potential_values[$mx_column] as $key=>$value){
				
				// if there is a match for it in the counts, figure out if it needs to be a leaf
				if(array_key_exists($value, $counts)){
					$counted = $counts[$value];

					// we have exactly one, needs to be a leaf node
					if(self::greaterThanZeroCount($counted) === 1){
						$leaf_node = new DTLeafNode();
						$leaf_node->setDecision(self::getValueThatIsGreaterThanZero($counted));
						$node->addChild($value, $leaf_node);
					}
					// have more than one node, need to recurse
					else{
						
						list($new_attrs, $new_classes) = self::getMatchingRows($attributes, $classes, $mx_column, $value);
						$new_attrs = rm_col($new_attrs, $mx_column);
						$node->addChild($value, self::build($new_attrs, $new_classes, $potential_values, $column_names));
					}

				}
				// have a potential value with no count, need to do voting
				else{
					$leaf_node = new DTLeafNode();
					$leaf_node->setDecision(self::voteForHighest($classes));
					$node->addChild($value, $leaf_node);
				}
			}

			return $node;
		}
	}

	public static function getMatchingRows($attributes, $classes, $column, $value){
		$new_attrs = array();
		$new_classes = array();
		foreach($attributes as $key=>$attr){
			if($attr[$column] === $value){
				$new_attrs[$key] = $attr;
				$new_classes[$key] = $classes[$key];
			}
		}
		return array($new_attrs, $new_classes);
	}

	public static function attributeCounts($column){
		$counts = array();
		foreach($column as $value){
			if(!array_key_exists($value, $counts)){
				$counts[$value] = 0;
			}
			$counts[$value]++;
		}
		return $counts;
	}

	public static function attributeCountsWithClasses($attributes, $classes){
		$ret = array();

		$unique_attr = array_unique($attributes);
		$unique_classes = array_unique($classes);

		foreach($unique_attr as $attr){
			$ret[$attr] = array();
			foreach($unique_classes as $class){
				$ret[$attr][$class] = 0;
			}
		}

		foreach($attributes as $key=>$attribute){
			$class = $classes[$key];
			$ret[$attribute][$class]++;
		}
		return $ret;
	}

	public static function entropyFromAttributeAndClasses($attribute, $classes){
		$counts = self::attributeCountsWithClasses($attribute, $classes);

		$entropy = 0;
		foreach($counts as $attr_count){
			$entropy += (array_sum($attr_count)/count($attribute)) * self::entropyFromCounts($attr_count);
		}

		return $entropy;
	}

	public static function entropyFromCounts($counts){
		$entropy = 0;
		$sum = array_sum($counts);
		foreach($counts as $k=>$v){
			$entropy += ($v === 0)?0:(-($v/$sum)*log($v/$sum,2));
		}
		return $entropy;
	}


	public static function informationGain($attribute, $classes){
		$attr_entropy = self::entropyFromCounts(self::attributeCounts($classes));
		$together_entropy = self::entropyFromAttributeAndClasses($attribute, $classes);
		return $attr_entropy - $together_entropy;
	}

	public static function maxInformationGain($attributes, $classes){
		$max = array(0, false);

		if(count($attributes) > 0){
			foreach(array_keys($attributes[key($attributes)]) as $key){
				$attribute = col($attributes, $key);

				$infoGain = self::informationGain($attribute, $classes);
				
				if($infoGain > $max[0]){
					$max = array($infoGain, $key);
				}
			}
		}

		return $max;
	}

	public static function greaterThanZeroCount($array){
		$count = 0;
		foreach($array as $value){
			if($value > 0){
				$count++;
			}
		}
		return $count;
	}

	public static function getValueThatIsGreaterThanZero($array){
		$val = null;
		foreach($array as $k=>$v){
			if($v > 0){
				$val = $k;
				break;
			}
		}
		return $val;
	}

	public static function voteForHighest($classes){
		$counts = array();
		foreach($classes as $class){
			if(!array_key_exists($class, $counts)){
				$counts[$class] = 0;
			}
			$counts[$class]++;
		}

		$max_val = 0;
		$max_class = '';
		foreach($counts as $class=>$count){
			if($count >= $max_val){
				$max_val = $count;
				$max_class = $class;
			}
		}

		return $max_class;
	}
}


class DTLeafNode{
	public $decision;
	
	public function __construct(){}

	public function setDecision($d){
		$this->decision = $d;
	}
}

class DTNode{
	public $column_index = -1;
	public $column_name = '';
	public $children = array();

	public function __construct(){}

	public function setColumnIndex($c){
		$this->column_index = $c;
		return $this;
	}

	public function setColumnName($c){
		$this->column_name = $c;
		return $this;
	}

	public function addChild($index, $c){
		$this->children[$index] = $c;
		return $this;
	}
}