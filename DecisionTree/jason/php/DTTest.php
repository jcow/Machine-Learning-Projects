<?php

require_once('DT.php');
require_once('DTBuilder.php');
require_once('Utils.php');

class DTBuilderTest extends PHPUnit_Framework_TestCase
{
    public function __construct(){}

    protected function setUp(){
        $this->predictors = read_csv("test_data/predictors.csv");
        $this->target = col(read_csv("test_data/target.csv"), 0);
    }

    public function testVoteForHighest(){
        $vote = DTBuilder::voteForHighest(array(
            'a', 'a', 'b', 'b', 'c', 'a'
        ));
        $this->assertEquals('a', $vote);

        $vote = DTBuilder::voteForHighest(array(
            'a', 'a', 'b', 'b', 'c', 'a', 'b', 'b'
        ));
        $this->assertEquals('b', $vote);
    }

    public function testGetMatchingRows(){
        list($attrs1, $classes1) = DTBuilder::getMatchingRows($this->predictors, $this->target, 1, "hot");
        $this->assertTrue(array_key_exists(0, $attrs1));
        $this->assertTrue(array_key_exists(1, $attrs1));
        $this->assertTrue(array_key_exists(2, $attrs1));
        $this->assertTrue(array_key_exists(12, $attrs1));

        $this->assertTrue(array_key_exists(0, $classes1));
        $this->assertTrue(array_key_exists(1, $classes1));
        $this->assertTrue(array_key_exists(2, $classes1));
        $this->assertTrue(array_key_exists(12, $classes1));

        $this->assertEquals("no", $classes1[0]);
        $this->assertEquals("no", $classes1[1]);
        $this->assertEquals("yes", $classes1[2]);
        $this->assertEquals("yes", $classes1[12]);
    }

    public function testMaxInformationGain(){
        list($mval1, $mvalcol) = DTBuilder::maxInformationGain($this->predictors, $this->target);
        $this->assertEquals(0.247, round($mval1, 3));

        list($mval2, $mvalcol2) = DTBuilder::maxInformationGain(rm_col($this->predictors, 0), $this->target);
        $this->assertEquals(0.152, round($mval2, 3));
    }

    public function testInformationGain(){
        $column1 = col($this->predictors, 0);
        $column2 = col($this->predictors, 1);
        $column3 = col($this->predictors, 2);
        $column4 = col($this->predictors, 3);

        $info_gain1 = DTBuilder::informationGain($column1, $this->target);
        $info_gain2 = DTBuilder::informationGain($column2, $this->target);
        $info_gain3 = DTBuilder::informationGain($column3, $this->target);
        $info_gain4 = DTBuilder::informationGain($column4, $this->target);

        $this->assertEquals(0.247, round($info_gain1, 3));
        $this->assertEquals(0.029, round($info_gain2, 3));
        $this->assertEquals(0.152, round($info_gain3, 3));
        $this->assertEquals(0.048, round($info_gain4, 3));
    }

    public function testEntropyFromAttributeAndClasses(){
        $column = col($this->predictors, 0);
        $entropy = DTBuilder::entropyFromAttributeAndClasses($column, $this->target);
        $this->assertEquals(0.694, round($entropy, 3));
    }

    public function testAttributeCounts(){
        $column = col($this->predictors, 0);
        $counts = DTBuilder::attributeCounts($column);
        $this->assertEquals(5, $counts["rainy"]);
        $this->assertEquals(5, $counts["sunny"]);
        $this->assertEquals(4, $counts["overcast"]);
    }

    public function testAttributeCountsWithClasses(){
        $column = col($this->predictors, 0);
        $counts = DTBuilder::AttributeCountsWithClasses($column, $this->target);
        $this->assertEquals(2, $counts["rainy"]["yes"]);
        $this->assertEquals(3, $counts["rainy"]["no"]);
        $this->assertEquals(3, $counts["sunny"]["yes"]);
        $this->assertEquals(2, $counts["sunny"]["no"]);
        $this->assertEquals(4, $counts["overcast"]["yes"]);
        $this->assertEquals(0, $counts["overcast"]["no"]);
    }

    public function testEntropyFromCounts(){
        $entropy = DTBuilder::entropyFromCounts(array(
            "yes"=>9, 
            "no"=>5
        ));

        $this->assertEquals(0.9403, round($entropy, 4));
    }
}