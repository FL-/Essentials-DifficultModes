#===============================================================================
# * Difficult Modes - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It allows a easy way to make difficult
# modes like the ones on Key System in BW2.
#
# You can set difficult levels that change the opponent parties to others that
# you can define and/or multiplier the levels of the pokémon and/or change
# the money earned after the battles. This script doesn't affect wild pokémon,
# but affects partner trainers.
#
#===============================================================================
#
# To this script works, put it above main.
# 
# In PokeBattle_Battle script section, before line (use Ctrl+F to find it)
# 'oldmoney=self.pbPlayer.money' add line
# 'maxlevel = DifficultModes.applyMoneyProcedure(maxlevel)'.
#
# In PokemonTrainers script section, change line
# 'def pbLoadTrainer(trainerid,trainername,partyid=0)' to
# 'def pbLoadTrainerDifficult(trainerid,trainername,partyid=0,procedure=nil)'. 
# Change line 'level=poke[1]' to
# 'level = DifficultModes.applyLevelProcedure(poke[1],procedure)'.
#
# You can see instructions for how to use in the 'def self.currentMode'.
# There two default difficulties already defined in this method,
# Easy Mode and Hard Mode, just follow the models.
#
#===============================================================================
module DifficultModes
  # Variable number that control the difficult.
  # To use a different variable, change this. 0 deactivates this script
  VARIABLE=90 
  
  def self.currentMode
    difficultHash={}
    
    
    easyMode = Difficult.new
    
    # partyid (six parameter) number for trainer than can have other party.
    # Trainers loaded this way ignores the levelProcedure.
    # IN THIS EXAMPLE: If you start a battle versus YOUNGSTER Ben team 1,
    # the game searches for the YOUNGSTER Ben team 101 (100+1),
    # if the game founds it loads instead of the team 1.
    easyMode.idJump = 100
    
    # A formula to change all trainers pokémon level. 
    # This affects money earned in battle.
    # IN THIS EXAMPLE: Every opponent pokémon that aren't found by idJump value
    # have the level*0.8 (round down). A pokémon level 6 will be level 4.
    easyMode.levelProcedure = proc{|level|
      next level*0.8
    }
    
    # A formula to change all trainers pokémon money.
    # This is the last formula to apply.
    # IN THIS EXAMPLE: Multiplier the money given by the opponent by 1.3 (round
    # down), so if the final money earned is 99, the money will be 128.
    easyMode.moneyProcedure = proc{|money|
      next money*1.3
    }
    # You can delete any of these three attributes if you didn't want them.
    
    # The Hash index is the value than when are in the VARIABLE number value,
    # the difficult will be ON.
    # IN THIS EXAMPLE: Only when variable 90 value is 1 than this changes
    # will occurs 
    difficultHash[1] = easyMode
    
    
    hardMode = Difficult.new
    hardMode.idJump = 200
    hardMode.levelProcedure = proc{|level|
      next level*1.2 + 1
    }
    hardMode.moneyProcedure = proc{|money|
      next money*0.8
    }
    difficultHash[2] = hardMode
    
    return DifficultModes::VARIABLE>0 ? 
      difficultHash[pbGet(DifficultModes::VARIABLE)] : nil
  end 
  
  def self.applyLevelProcedure(level,procedure)
    return procedure ? 
      [[procedure.call(level).floor,MAXIMUMLEVEL].min,1].max : level
  end
  
  def self.applyMoneyProcedure(money)
    difficultSelected = self.currentMode
    return difficultSelected && difficultSelected.moneyProcedure ? 
      [difficultSelected.moneyProcedure.call(money).floor,0].max : money
  end
  
  def self.loadTrainer(trainerid,trainername,partyid=0)
    trainer = nil
    procedure = nil
    difficultSelected = self.currentMode
    if difficultSelected
      trainer=pbLoadTrainerDifficult(trainerid,trainername,
        partyid + difficultSelected.idJump) if difficultSelected.idJump>0
      procedure = difficultSelected.levelProcedure
    end
    return trainer ? trainer : pbLoadTrainerDifficult(
      trainerid,trainername,partyid,procedure)
  end
    
  private
  class Difficult
    attr_accessor :idJump
    attr_accessor :levelProcedure
    attr_accessor :moneyProcedure
    
    def initialize
      @idJump = 0
      @levelProcedure = nil
      @moneyProcedure = nil
    end  
  end  
end

def pbLoadTrainer(trainerid,trainername,partyid=0)
  return DifficultModes.loadTrainer(trainerid,trainername,partyid)
end