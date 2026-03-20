#!/usr/bin/env python3

import re
import os
import sys
from file_io import FileIO
#from pathlib import Path
from typing import Dict, Any, Optional

class EventAnalyzer:
    error_count = 0

    def __init__(self):
        self.reset()
    
    def reset(self):
        self.content = ""

        self.data = {
            'UnhandledLines': [],

            'EventID': None,
            'FileName': None,
            'RequiredDLC': [],
            'TimeOfDay': None,
            'NumberOfOpenRosterSlots': None,
            'MinimumBrotherCount': None,
            'MaximumBrotherCount': None,
            'MininumCrowns': None,
            'MinDistanceFromSettlement': None,
            'MaxDistanceFromSettlement': None,
            'SettlementType': None, #Southern, Northern T1-T2-T3-Military-NonMilitary
            'SettlementSituation': None,
            'SettlementMustNotBeHostile': None,
            'TileRequirements': None,
            'BackgroundRequirements': [],
            'BackgroundsUnlockingExtraInteractions': [],
            'OriginRequirements': [],
            'RequiredOrigins': [],
            'ExcludedOrigins': [],
            'RequiredCrises': None,
            'RequiredCrisesStatus': None,
            'MinimumDays': None,
            'MaximumDays': None,
            'NumberOfEmptyInventorySlots': None,
            'PlayerCharacterExcluded': None,
            'PlayerCharacterRequired': None,
            'ExcludedItems': [],
            'RequiredItems': [],
            'ExcludedFlags': [],
            'RequiredFlags': [],
            'SpecialConsiderations': [],
            'RequiredRetinue': [],
            'ExcludedRetinue': [],
            'CandidateRequiredTraits': [],
            'CandidateExcludedTraits': []
        }
        
        self.current_event_id = None
        #self.iterates_through_roster = False
        self.location_check_variable = ""
        self.item_check_variable = ""

        self.candidates_checked = []

        self.dlc_map = {
            "Lindwurm": "Lindwurm",
            "Unhold": "Beasts & Exploration",
            "Wildmen": "Warriors Of The North",
            "Desert": "Blazing Deserts",
            "Paladins": "Of Flesh And Faith"
        }

        self.crises_map = {
            "isHolyWar": "Holy War",
            "isCivilWar": "Noble War",
            "isGreenskinInvasion": "Greenskin Invasion",
            "isUndeadScourge": "Undead Invasion"
        }

        self.greater_evil_map = {
            "HolyWar": "Holy War",
            "CivilWar": "Noble War",
            "Greenskins": "Greenskin Invasion",
            "Undead": "Undead Invasion"
        }

        self.map_items = {
            "misc.black_book": "The Black Book",
            "misc.quality_wood": "Quality Wood",
            'misc.werewolf_pelt': "Unusually Large Wolf Pelt",
            "misc.ghoul_teeth": "Jagged Fangs",
            "misc.poisoned_apple": "misc.poisoned_apple",
            "misc.petrified_scream": "Petrified Scream"
        }

        self.flag_map = {
            "IsLorekeeperDefeated": "Lorekeeper is defeated",
            "IsHoggartDead": "Hoggart is defeated [Req. Tutorial Origin]"
        }

        self.retinue_map = {
            "follower.scout": "Scout",
            "follower.cook": "Cook",
            "follower.paymaster": "Paymaster"
        }

        self.trait_map = {
            "trait.mad": "Mad"
        }

    def iterate_through_squirrel_files(self, directory: str, output_file: str = 'event_requirements'):
        results = []
        squirrel_files = FileIO.get_squirrel_files_in_directory(directory)

        if not squirrel_files:
            print("No squirrel .nut files found in the directory that you passed in.")
            return

        print(f"Found {len(squirrel_files)} .nut files")

        for i, filepath in enumerate(squirrel_files, 1):
            print(f"Processing {i}/{len(squirrel_files)}...")
            
            result = self.analyze_file(str(filepath))
            if result:
                results.append(result)

        print(f"\nAnalyzed {len(results)} event files with requirements")
        print(f"\n{self.error_count} unhandled lines")

        #print(results)
        
        FileIO.generate_json_file(results, output_file + '.json')
        FileIO.generate_squirrel_file(results, output_file + '.nut')
        print(f"Generated {output_file}")

    def analyze_file(self, filepath: str) -> Optional[Dict[str, Any]]:
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {filepath}: {e}", file=sys.stderr)
            return None
        
        if self.file_should_not_be_processed(content):
            return None
        
        if self.file_is_for_a_special_event(content):
            return None
        
        self.reset()

        self.data['FileName'] = os.path.basename(filepath)
        self.data['EventID'] = self.extract_event_id(content)
        self.current_event_id = self.data['EventID']

        on_update_score = FileIO.extract_function_from_file(content, 'onUpdateScore')
        if not on_update_score:
            return None
        
        self.content = on_update_score

        self.analyze_on_update_score_function(on_update_score)

        #Clean up - remove None values
        result = {}
        for k, v in self.data.items():
            if v is not None and v != []:
                result[k] = v
        
        return result if len(result) > 1 else None
    
    def file_should_not_be_processed(self, content: str) -> bool:
        if 'onUpdateScore' not in content:
            return True
        
        return False

    def file_is_for_a_special_event(self, content: str) -> bool:
        if 'this.m.IsSpecial = true;' in content:
            return True
        
        return False
    
    def extract_event_id(self, content: str) -> str:
        match = re.search(r'this\.m\.ID\s*=\s*"([^"]+)"', content)
        if match:
            print(match.group(1))
            return match.group(1)
        
        return "unknown"
    
    def analyze_on_update_score_function(self, func_body: str):
        lines = func_body.split('\n')
        
        for i, line in enumerate(lines):
            line = line.strip()

            handled = False

            if not self.line_should_be_evaluated(line):
                continue
            
            if self.line_is_for_specific_event_override(line):
                continue

            handled = self.line_is_for_DLC_check(line) or handled
            handled = self.line_is_for_time_of_day_check(line) or handled
            handled = self.line_is_for_open_roster_check(line) or handled
            handled = self.line_is_for_money_check(line) or handled
            handled = self.line_is_for_tile_check(line) or handled
            handled = self.line_is_for_brother_background_check(line) or handled
            handled = self.line_is_for_a_trait_check(line) or handled
            handled = self.line_is_for_candidate_check(line) or handled
            handled = self.line_is_for_origin_check(line) or handled
            handled = self.line_is_for_crises_event(line) or handled
            handled = self.line_is_for_day_check(line) or handled
            handled = self.line_is_for_inventory_check(line) or handled
            handled = self.line_is_for_player_check(line) or handled 
            handled = self.line_is_for_item_check(line) or handled
            handled = self.line_is_for_flags_check(line) or handled
            handled = self.line_is_for_retinue_check(line) or handled

            if not handled:
                EventAnalyzer.error_count += 1
                self.data['UnhandledLines'].append(line)
                #print(line)

    def line_should_be_evaluated(self, line: str) -> bool:
        if not line:
            return False

        if line.find('//') != -1:
            return False
        
        if len(line) < 4:
            return False
        
        if line.startswith('local ') or line.startswith('return'):
            return False
        
        if '{' in line or '}' in line:
            return False
        
        if 'if (this.m.Town == null)' in line:
            return False
        
        match = re.search(r'if\s*\(', line)

        if not match:
            return False
    
        return True
    
    def line_is_for_specific_event_override(self, line: str) -> bool:

        if self.current_event_id == "event.trade_black_book":
            if '(this.World.Assets.getOrigin().getID() != "scenario.militia")' in line:
                self.data['SpecialConsiderations'].append("The Peasant Militia origin qualifies without having a bro with the Mad Trait.")
                self.data['SpecialConsiderations'].append("The Peasant Militia origin skips the Read Black Book event.")
                #self.data['SpecialConsiderations'].append("All other origins must complete the Read Black Book event and must have the Mad brother in the roster.")
                return True
            
            # if 'bro.getSkills().hasSkill("trait.mad")' in line:
            #     return True
            
            # if 'candidates_mad.len() == 0' in line:
            #     return True

        if self.current_event_id == "event.sword_eater":
            if 'if (this.Const.DLC.Wildmen && !this.World.Flags.get("IsSwordEaterWildmanDone") && bro.getBackground().getID() == "background.wildman")' in line:
                self.data['SpecialConsiderations'].append("Warriors of the North DLC & a Wildman in the roster can unlock a special Wildman interaction 1 time.")
                return True
            
            if 'if (bro.getSkills().hasSkill("trait.player"))' in line:
                return True
            
            if 'if (candidates_wildman.len() != 0)' in line:
                return True
            
        if self.current_event_id == "event.arena_tournament" and 'if (town == null)' in line:
            return True
        
        if self.current_event_id == "event.cultural_conflagration":
            if "if (bro.getEthnicity() == 0)" in line:
                self.data['SpecialConsiderations'].append("Must have at least 1 southern and 1 northern ethnicity bro.")
                return True
            
            if "if (northern <= 1 || southern <= 1)" in line:
                return True
            
        if self.current_event_id == "event.pirates":
            if 'this.World.Assets.getOrigin().getID() == "scenario.manhunters"' in line:
                self.data['SpecialConsiderations'].append("Manhunters origin must have 2 open roster slot.")
                return True
        
        if self.current_event_id == "event.desert_bugbite":
            if 'lowestBro' in line:
                self.data['SpecialConsiderations'].append("The lowest health brother without Strong, Tough, Lucky, or Southern ethnicity is most likely to be bitten.")
                self.data['SpecialConsiderations'].append("A bro that is Exhausted will not be bitten.")
                # self.data['SpecialConsiderations'].append("Strong, Tough, Lucky, or a Southern ethnicity bro is less likely to get bit.")
                return True
            
            if 'bro.m.Ethnicity' in line or 'lowestChance' in line or 'bro.getSkills().hasSkill' in line:
                return True

        if self.current_event_id == "event.desert_fall":
            if 'lowestBro' in line:
                self.data['SpecialConsiderations'].append("The lowest health brother without Strong, Tough, Lucky, and Southern ethnicity is most likely to fall.")
                self.data['SpecialConsiderations'].append("A bro that has a Bruised Leg will not fall.")
                return True
           
            if 'bro.m.Ethnicity' in line or 'lowestChance' in line or 'bro.getSkills().hasSkill' in line:
                return True
            
        if self.current_event_id == "event.desert_feet":
            if '(bro.m.Ethnicity == 1)' in line:
                self.data['SpecialConsiderations'].append("Must have 3 or more northern ethnicity bros.")
                return True
            
            if 'if (numNortherners < 3)' in line:
                return True
            
        if self.current_event_id == "event.desert_heat":
            if 'lowestBro' in line:
                self.data['SpecialConsiderations'].append("The lowest health brother without Strong, Tough, Lucky, and Southern ethnicity is most likely to become Exhausted.")
                self.data['SpecialConsiderations'].append("A bro that has is Exhausted will not get heat stroke.")
                return True
            
            if 'bro.m.Ethnicity' in line or 'lowestChance' in line or 'bro.getSkills().hasSkill' in line:
                return True

        if self.current_event_id == "event.gladiators_food":
            if 'item.getRawValue() >= 85' in line:
                self.data['SpecialConsiderations'].append("Requires only food stacks valued at 84 or fewer crowns.")
                return True

            if 'if (hasExquisiteFood)' in line or 'isItemType(this.Const.Items.ItemType.Food)' in line:
                return True

        return False

    def line_is_for_DLC_check(self, line: str) -> bool:
        if 'Const.DLC' not in line:
            return False
        
        matches = re.findall(r'(!?)\s*this\.Const\.DLC\.(\w+)', line)

        if matches:
            for match in matches:
                boolCheck = match[0]
                dlc = match[1]

                # if (!this.Const.DLC.Desert) .. return false .. no event score
                if boolCheck == "!":
                    self.data["RequiredDLC"].append(self.dlc_map[dlc])

            return True

        return False        

    def line_is_for_time_of_day_check(self, line: str) -> bool:
        if 'getTime()' not in line:
            return False

        match = re.search(r'if\s*\(\s*(!?)\s*this\.World\.getTime\(\)\.IsDaytime\)', line)

        if match:
            boolCheck = match.group(1)

            # if ([!]this.World.getTime().IsDaytime) ... return
            if boolCheck == "!":
                self.data["TimeOfDay"] = "Day"
            else:
                self.data["TimeOfDay"] = "Night"

            return True

        return False
    
    def line_is_for_open_roster_check(self, line: str) -> bool:
        if 'getPlayerRoster().getSize()' not in line and 'brothers.len()' not in line:
            return False
        
        print("_line_is_for_open_roster_check", line)

        match = re.search(r'len\(\)\s(<|>|=|<=|=>)\s(\d+)', line)
        if match:
            operator = match.group(1)
            number = int(match.group(2))

            if '>=' in operator:
                self.data['MaximumBrotherCount'] = number + 1
            elif "<=" in operator:
                self.data['MinimumBrotherCount'] = number + 1
            elif '>' in operator:
                self.data['MaximumBrotherCount'] = number
            elif '<' in operator:
                self.data['MinimumBrotherCount'] = number
            
            return True
        
        match = re.search(r'this\.World\.getPlayerRoster\(\)\.getSize\(\)\s(>=|<=|>|<|==|!=)\sthis\.World\.Assets\.getBrothersMax\(\)', line)
        if match:
            operator = match.group(1)

            if '>=' in operator:
                self.data['NumberOfOpenRosterSlots'] = 1
            
            return True
            
            # if '<=' in operator:
            #     self.data['MinimumBrothers'] = size
            # elif '>=' in operator:
            #     self.data['MaximumBrothers'] = size
            # elif '<' in operator and '<=' not in operator:
            #     self.data['MinimumBrothers'] = size
            # elif '>' in operator and '>=' not in operator:
            #     self.data['MaximumBrothers'] = size
            # return True

        

        return False
    
    def line_is_for_money_check(self, line: str) -> bool:
        if 'getMoney()' not in line:
            return False
        
        match = re.search(r'getMoney\(\)\s*([<>=!]+)\s*(\d+)', line)
        
        if match:
            operator = match.group(1)
            amount = int(match.group(2))
            
            if '<=' in operator:
                self.data['MinimumCrowns'] = amount
            elif '<' in operator:
                self.data['MinimumCrowns'] = amount + 1
            return True
        
        return False
    
    def line_is_for_tile_check(self, line: str) -> bool:
        matched_location = False
        tileDetails = {}

        if 'isSouthern()' in line:
            self.data['SettlementType'] = "Southern"
            matched_location = True

        if '!t.isSouthern()' in line:
            self.data['SettlementType'] = "Northern"
            matched_location = True

        if 'isMilitary()' in line:
            self.data['SettlementType'] = "Military"
            matched_location = True

        if 'isMilitary()' in line:
            self.data['SettlementType'] = "Non-Military"
            matched_location = True

        if 't.hasSituation("situation.arena_tournament"' in line:
            self.data['SettlementSituation'] = "Must have Arena Tournament Settlement Situation"
            matched_location = True

        if 'getTile().getDistanceTo' in line:
            match = re.search(r'getDistanceTo.*?([<>=!]+)\s*(\d+)', line)

            if match:
                matched_location = True
                operator = match.group(1)
                distance = int(match.group(2))

                if_statement_contents = FileIO.get_if_block_contents(self.content, line)

                if if_statement_contents == "":
                    matched_location = False
                else:
                    if_lines = if_statement_contents.split('\n')

                    if 'return' in if_statement_contents:
                        if '>=' in operator:
                            self.data['MaxDistanceFromSettlement'] = distance + 1
                        elif '<=' in operator:
                            self.data['MinDistanceFromSettlement'] = distance + 1
                        elif '>' in operator:
                            self.data['MaxDistanceFromSettlement'] = distance
                        elif '<' in operator:
                            self.data['MinDistanceFromSettlement'] = distance
                    elif 'break;' in if_statement_contents:
                        if '>=' in operator:
                            self.data['MinDistanceFromSettlement'] = distance
                        elif '<=' in operator:
                            self.data['MaxDistanceFromSettlement'] = distance
                        elif '>' in operator:
                            self.data['MinDistanceFromSettlement'] = distance + 1
                        elif '<' in operator:
                            self.data['MaxDistanceFromSettlement'] = distance + 1

                        if len(if_lines) > 2:
                            return False
                        
                        if 'break;' in if_lines[1]:
                            matches = re.search(r'([\w.]+)\s*(=|!=)\s*([\w.]+)', if_lines[0])

                            if matches:
                                self.location_check_variable = matches.group(1)
                                print("Just set Location Check to: " + self.location_check_variable)
                    
        if 'bestDistance' in line:
            self.location_check_variable = 'bestDistance'
        if 'closest' in line:
            self.location_check_variable = 'closest'
            #print("Just set Location Check to: " + self.location_check_variable)
                        
        #if (!nearTown)
        if len(self.location_check_variable) > 0 and self.location_check_variable in line and 'getTile().getDistanceTo' not in line:
            matched_location = True
            variable_check = '!' + self.location_check_variable

            if variable_check in line and 'return' in FileIO.get_if_block_contents(self.content, line):
                #we've already documented the requirements for this location
                matched_location = True

            matches = re.findall(rf'{self.location_check_variable}\s*(=|!=|<|>|<=|>=)\s*(\d+)', line)

            if matches:
                for matches in matches:
                    #print("Matched: " + self.location_check_variable)
                    operator = matches[0]
                    distance = int(matches[1])

                    if '>=' in operator:
                        self.data['MaxDistanceFromSettlement'] = distance + 1
                    elif '<=' in operator:
                        self.data['MinDistanceFromSettlement'] = distance + 1
                    elif '>' in operator:
                        self.data['MaxDistanceFromSettlement'] = distance
                    elif '<' in operator:
                        self.data['MinDistanceFromSettlement'] = distance

        if '!isAlliedWithPlayer()' in line:
            matched_location = True
            self.data['SettlementMustNotBeHostile'] = False
        elif 'isAlliedWithPlayer()' in line:
            matched_location = True
            self.data['SettlementMustNotBeHostile'] = True

        if '!currentTile.HasRoad' in line or '!currentTile.HasRoad' in line:
            matched_location = True
            tileDetails["Road"] = "OnRoad"
        elif 'currentTile.HasRoad' in line or 'currentTile.HasRoad' in line:
            matched_location = True
            tileDetails["Road"] = "OffRoad"

        if 'currentTile.Type' in line:
            matches = re.findall(r'([\w.]+)\s*(==|!=)\s*this\.Const\.World\.TerrainType\.(\w+)', line)

            if matches:
                newlist = []

                for match in matches:
                    operator = match[1]
                    terrainType = match[2]

                    newlist.append(terrainType)

                    if '!=' in operator:
                        matched_location = True

                    tileDetails["TerrainType"] = ", ".join(newlist)

        if 'currentTile.TacticalType' in line:
            matches = re.findall(r'([\w.]+)\s*(==|!=)\s*this\.Const\.World\.TerrainTacticalType\.(\w+)', line)

            if matches:
                for match in matches:
                    matched_location = True
                    operator = match[1]
                    tactical_type = match[2]

                    if '!=' in operator:
                        tileDetails["TacticalType"] = tactical_type

        # currentTile.SquareCoords.Y > this.World.getMapSize().Y * 0.7
        if "SquareCoords" in line and "getMapSize()" in line:
            match = re.search(r'([<>=!]+)\s*this\.World\.getMapSize\(\)\.Y\s*\*\s*(\d+\.\d+)', line)

            if match:
                matched_location = True
                operator = match.group(1)
                y_value = float(match.group(2))
                y_percent = int(y_value * 100)

                if ">=" in operator:
                    tileDetails["OnOrBelowYLine"] = y_percent
                elif "<=" in operator:
                    tileDetails["OnOrAboveYLine"] = y_percent
                elif ">" in operator:
                    tileDetails["BelowYLine"] = y_percent
                elif "<" in operator:
                    tileDetails["AboveYLine"] = y_percent

        if tileDetails:
            if self.data['TileRequirements'] is not None:
                self.data['TileRequirements'].update(tileDetails)
            else:
                self.data['TileRequirements'] = tileDetails

        return matched_location
    
    def line_is_for_brother_background_check(self, line: str) -> bool:
        if 'getBackground().getID()' not in line:
            return False
        
        found_match = False
        
        if_statement_lines = FileIO.get_if_block_contents(self.content, line)
        else_lines = FileIO.get_else_block_contents(self.content, line)

        if 'getBackground()' in line and 'getLevel()' not in line: 
            matches = re.findall(r'getBackground\(\)\.getID\(\)\s*(==|!=)\s*"([^"]+)"', line)

            if matches:
                for match in matches:
                    operator = match[0]
                    background_str = match[1]
                
                    background_name = background_str.replace('background.', '')

                    print("evaluating background: " + background_name)

                    if "==" in operator and background_name not in self.data['BackgroundRequirements']:
                        if 'return' in if_statement_lines:
                            found_match = True
                            continue

                        found_match = True

                    if 'candidate' in if_statement_lines:
                        self.candidates_checked.append({"candidate_variable": if_statement_lines.split('\n')[0].split('.')[0], "background": background_name})
                    
                    if 'return' in if_statement_lines:
                        None

                    if 'candidate' in else_lines:
                        self.candidates_checked.append({"candidate_variable": else_lines.split('\n')[0].split('.')[0], "background": "other"})

        elif 'getBackground()' in line and 'getLevel()' in line:
            if line.index('getBackground()') < line.index('getLevel()'):
                matches = re.findall(r'(==|!=)\s*"([\w.]+)".*?bro\.getLevel\(\)\s*(>=|<=|>|<|==|!=)\s*(\d+)', line)

                if matches:
                    for match in matches:
                        bkgrnd_operator = match[0]
                        background_str = match[1]
                        level_operator = match[2]
                        level = int(match[3])

                        if '==' in bkgrnd_operator:
                            min_level = 0
                            max_level = 0

                            if '>=' in level_operator:
                                min_level = level
                            elif '>' in level_operator:
                                min_level = level + 1
                            elif '<=' in level_operator:
                                max_level = level
                            elif '<' in level_operator:
                                max_level = level - 1

                            background_name = background_name = background_str.replace('background.', '')
                            self.data['BackgroundRequirements'].append({"background": background_name, "minLevel": min_level, "maxLevel": max_level})

                            if 'candidate' in if_statement_lines:
                                self.candidates_checked.append({"candidate_variable": if_statement_lines.split('\n')[0].split('.')[0], "background": "other"})
                            
                            if 'return' in if_statement_lines:
                                None

                            if 'candidate' in else_lines:
                                self.candidates_checked.append({"candidate_variable": else_lines.split('\n')[0].split('.')[0], "background": "other"})

                return True
            elif 'getBackground()' in line and 'IsPlayerCharacter()' in line:
                matches = re.findall(r'getBackground\(\)\.getID\(\)\s*(==|!=)\s*"([^"]+)"', line)

                if matches:
                    for match in matches:
                        operator = match[0]
                        background_str = match[1]
                    
                        background_name = background_str.replace('background.', '')

                        if "==" in operator and background_name not in self.data['BackgroundRequirements']:
                            if 'return' in if_statement_lines:
                                found_match = True
                                continue
         
                            found_match = True

                        if 'candidate' in if_statement_lines:
                            self.candidates_checked.append({"candidate_variable": if_statement_lines.split('\n')[0].split('.')[0], "background": background_name, "IsPlayerCharacter": True})
                        
                        if 'return' in if_statement_lines:
                            None

                        if 'candidate' in else_lines:
                            self.candidates_checked.append({"candidate_variable": else_lines.split('\n')[0].split('.')[0], "background": "other"})
            else:
                matches = re.findall(r'bro\.getLevel\(\)\s*(>=|<=|>|<|==|!=)\s*(\d+).*?(==|!=)\s*"([\w.]+)"', line)

                if matches:
                    for match in matches:
                        bkgrnd_operator = match[2]
                        background_str = match[3]
                        level_operator = match[0]
                        level = int(match[1])

                        if '==' in bkgrnd_operator:
                            min_level = 0
                            max_level = 0

                            if '>=' in level_operator:
                                min_level = level
                            elif '>' in level_operator:
                                min_level = level + 1
                            elif '<=' in level_operator:
                                max_level = level
                            elif '<' in level_operator:
                                max_level = level - 1

                            background_name = background_name = background_str.replace('background.', '')
                            self.data['BackgroundRequirements'].append({"background": background_name, "minLevel": min_level, "maxLevel": max_level})

                            if 'candidate' in if_statement_lines:
                                self.candidates_checked.append({"candidate_variable": if_statement_lines.split('\n')[0].split('.')[0], "background": "other"})
                            
                            if 'return' in if_statement_lines:
                                None

                            if 'candidate' in else_lines:
                                self.candidates_checked.append({"candidate_variable": else_lines.split('\n')[0].split('.')[0], "background": "other"})

                return True
        return found_match
    
    def line_is_for_a_trait_check(self, line: str) -> bool:
        if 'bro.getSkills()' not in line:
            return False
    
        match = re.search(r'hasSkill\("([^"]+)"\)', line)
        if_statement_lines = FileIO.get_if_block_contents(self.content, line)

        if match:
            trait = match.group(1)
            if 'return' in if_statement_lines:
                self.data["CandidateExcludedTraits"].append(self.trait_map[trait])
                return True
            
            if 'candidate' in if_statement_lines:
                self.candidates_checked.append({"candidate_variable": if_statement_lines.split('\n')[0].split('.')[0], "background": "none", "trait": self.trait_map[trait]})
                return True
            
        return False

    def line_is_for_candidate_check(self, line: str) -> bool:
        if ('candidate' not in line and 'len()' not in line) or len(self.candidates_checked) == 0:
            return False
        
        candidate_matched = False
        
        if_statement_lines = FileIO.get_if_block_contents(self.content, line)

        # print("Candidates found")
        # print(self.candidates_checked)

        for candidate in self.candidates_checked:
            print("Candidate in the candidates list: " + candidate["background"])
            match = re.search(rf'{candidate["candidate_variable"]}.len\(\)\s*([<>=!]+)\s*(\d+)', line)

            if match:
                operator = match.group(1)
                number = int(match.group(2))

                if '!=' in operator and number == 0:
                    if candidate['background'] == "none":
                        None
                    elif 'return' in if_statement_lines:
                        self.data['BackgroundRequirements'].append({"background": candidate["background"], "minLevel": 0, "maxLevel": 0})
                    else:
                        self.data['BackgroundsUnlockingExtraInteractions'].append({"background": candidate["background"], "minLevel": 0, "maxLevel": 0})

                    candidate_matched = True
                elif '==' in operator and number == 0 and 'return' in if_statement_lines:
                    if candidate['background'] == "none":
                        self.data['CandidateRequiredTraits'].append(candidate["trait"])
                        candidate_matched = True
                    if candidate['background'] == "other":
                        candidate_matched = True
                    else:
                        self.data['BackgroundRequirements'].append({"background": candidate["background"], "minLevel": 0, "maxLevel": 0})
                    candidate_matched = True
                elif '<' in operator and number > 0 and 'return' in if_statement_lines:
                    if candidate['background'] == "other":
                        candidate_matched = True
                    else:
                        self.data['BackgroundRequirements'].append({"background": candidate["background"], "minLevel": 0, "maxLevel": 0, "IsPlayerCharacter": candidate.get("IsPlayerCharacter", "")})
                    candidate_matched = True

        return candidate_matched

    def line_is_for_origin_check(self, line: str) -> bool:
        #if (this.World.Assets.getOrigin().getID() != "scenario.gladiators")
        if 'getOrigin().getID()' not in line:
            return False
        
        matches = re.findall(r'(==|!=)\s*"([\w.]+)', line)

        if matches:
            for match in matches:
                operator = match[0]
                origin_str = match[1]

                origin = origin_str.replace('origin.', '')

                if "==" in operator:
                    self.data['ExcludedOrigins'].append(origin)
                elif "!=" in operator:
                    self.data['RequiredOrigins'].append(origin)

            return True
        return False

    def line_is_for_crises_event(self, line: str) -> bool:
        if ('isHolyWar()' not in line and 'isCivilWar()' not in line 
            and 'isGreenskinInvasion()' not in line and 'isUndeadScourge()' not in line
            and 'getGreaterEvilType()' not in line):
            return False
        
        if 'getGreaterEvilType()' not in line:
            match = re.search(r'(!?)\s*this\.World\.FactionManager\.(\w+)\(\)', line)

            if match:
                boolCheck = match.group(1)
                crises = match.group(2)

                # if (!this.World.FactionManager.isHolyWar())
                if boolCheck == "!":
                    self.data["RequiredCrises"] = self.crises_map[crises] 
                
                return True
            
        else:
            matched_line = False

            if 'getGreaterEvilType()' in line:
                match = re.search(r'(==|!=)\s*this\.Const\.World\.GreaterEvilType\.(\w+)', line)

                if match:
                    matched_line = True
                    operator = match.group(1)
                    greater_evil_type = match.group(2)

                    if '==' in operator:
                        self.data["RequiredCrises"] = self.greater_evil_map[greater_evil_type]

            if 'getGreaterEvilPhase()' in line:
                match = re.search(r'(==|!=)\s*this\.Const\.World\.GreaterEvilPhase\.(\w+)', line)

                if match:
                    matched_line = True
                    operator = match.group(1)
                    greater_evil_phase = match.group(2)

                    if '==' in operator:
                        self.data["RequiredCrisesStatus"] = greater_evil_phase

            return matched_line

        return False
    
    def line_is_for_day_check(self, line: str) -> bool:
        if 'getTime()' not in line: 
            return False
        
        match = re.search(r'getTime\(\)\.Days\s*([<>=!]+)\s*(\d+)', line)
        
        #this.World.getTime().Days > 10
        if match:
            operator = match.group(1)
            days = int(match.group(2))

            if '<' in operator:
                self.data['MinimumDays'] = days #+ 1
            elif '<=' in operator:
                self.data['MinimumDays'] = days + 1
            elif '>' in operator:
                self.data['MaximumDays'] = days #+ 1
            elif '>=' in operator:
                self.data['MaximumDays'] = days + 1
        
            return True

        return False
    
    def line_is_for_inventory_check(self, line: str) -> bool:
        if 'getStash()' not in line: 
            return False

        #'if (!this.World.Assets.getStash().hasEmptySlot())'
        match = re.search(r'if\s*\(\s*(!?)\s*this\.World\.Assets\.getStash\(\)\.hasEmptySlot\(\)\)', line)

        if match:
            if '!' in match.group(1):
                self.data['NumberOfEmptyInventorySlots'] = 1

            return True
        
        #"if (this.World.Assets.getStash().getNumberOfEmptySlots() < 1)"
        match = re.search(r'getStash\(\)\.getNumberOfEmptySlots\(\)\s*([<>=!]+)\s*(\d+)', line)
        
        if match:
            operator = match.group(1)
            slots = int(match.group(2))

            if '<' in operator or '<=' in operator:
                self.data['NumberOfEmptyInventorySlots'] = slots
            elif '>' in operator:
                self.data['NumberOfEmptyInventorySlots'] = slots + 1
            elif '>=' in operator:
                self.data['NumberOfEmptyInventorySlots'] = slots
        
            return True
        
        return False

    def line_is_for_player_check(self, line: str) -> bool:
        if 'asSkill("trait.player")' not in line and '"IsPlayerCharacter")' not in line:
            return False
        
        if_statement = FileIO.get_if_block_contents(self.content, line)

        if 'continue' in if_statement:
            self.data['PlayerCharacterExcluded'] = True
            return True
        
        if 'IsPlayerCharacter' in line:
           # self.data['PlayerCharacterRequired'] = True
            return True

        return False
    
    def line_is_for_item_check(self, line: str) -> bool:
        matched_item = False

        # if 'item.getID()' not in line:
        #     return False
        
        # foreach( item in stash )
		# {
		# 	if (item != null && item.getID() == "misc.black_book")
		# 	{
		# 		hasBlackBook = true;
		# 		break;
		# 	}
		# }

		# if (!hasBlackBook)
		# {
		# 	return;
		# }
        
        match = re.search(r'item\.getID\(\)\s*(==|!=)\s*"([\w.]+)"', line)
        
        if match:
            print("_line_is_for_item_check")
            operator = match.group(1)
            item = match.group(2)

            if "==" in operator:
                matched_item = True
                if_statement_contents = FileIO.get_if_block_contents(self.content, line)

                if if_statement_contents == "":
                    matched_item = False
                else:
                    if_lines = if_statement_contents.split('\n')

                    if 'return' in if_statement_contents:
                        self.data['ExcludedItems'].append(self.map_items[item])
                    elif 'break;' in if_statement_contents:
                        self.data['RequiredItems'].append(self.map_items[item])

                        if len(if_lines) > 2:
                            return False
                        
                        if 'break;' in if_lines[1]:
                            match = re.search(r'([\w.]+)\s*(=|!=)\s*([\w.]+)', if_lines[0])

                            if match:
                                self.item_check_variable = match.group(1)
                                print("Just set Item Check to: " + self.item_check_variable)
                    
        # if 'bestDistance' in line:
        #     self.location_check_variable = 'bestDistance'
        # if 'closest' in line:
        #     self.location_check_variable = 'closest'
            #print("Just set Location Check to: " + self.location_check_variable)
                        
        #if (!hasBlackBook)
        if len(self.item_check_variable) > 0 and self.item_check_variable in line and 'item.getID()' not in line:
            matched_item = True
            variable_check = '!' + self.item_check_variable

            if variable_check in line and 'return' in FileIO.get_if_block_contents(self.content, line):
                #we've already documented the requirements for this location
                matched_item = True

            # matches = re.findall(rf'{self.item_check_variable}\s*(=|!=|<|>|<=|>=)\s*(\d+)', line)

            # if matches:
            #     for match in matches:
            #         #print("Matched: " + self.location_check_variable)
            #         operator = match[0]
            #         distance = int(match[1])

            #         if '>=' in operator:
            #             self.data['MaxDistanceFromSettlement'] = distance + 1
            #         elif '<=' in operator:
            #             self.data['MinDistanceFromSettlement'] = distance + 1
            #         elif '>' in operator:
            #             self.data['MaxDistanceFromSettlement'] = distance
            #         elif '<' in operator:
            #             self.data['MinDistanceFromSettlement'] = distance
            
        return matched_item
    
    def line_is_for_flags_check(self, line: str) -> bool:
        # if (!this.World.Flags.get("IsLorekeeperDefeated"))
        if 'World.Flags.get' not in line:
            return False
        
        match = re.search(r'(!?)this\.World\.Flags\.get\("(\w+)"\)', line)

        if match:
            operator = match.group(1)
            flagName = match.group(2)

            if "!" in operator:
                self.data['RequiredFlags'].append(self.flag_map[flagName])
                return True
            
        return False
    
    def line_is_for_retinue_check(self, line: str) -> bool:
        #this.World.Retinue.hasFollower("follower.scout")
        if 'Retinue.hasFollower' not in line:
            return False
        
        match = re.search(r'(!?)\s*this\.World\.Retinue\.hasFollower\("([\w.]+)"\)', line)

        if match:
            operator = match.group(1)
            follower = match.group(2)

            if '!' in operator:
                self.data['RequiredRetinue'].append(self.retinue_map[follower])
                return True
            
            if '' in operator:
                self.data['ExcludedRetinue'].append(self.retinue_map[follower])
                return True
        
        return False