"""Exercise invalid future content without editing the actual game catalogue."""
import copy
import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scripts.audit_content import load_documents, validate, unique_object


class ContentAuditTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.documents, errors = load_documents()
        assert not errors, errors

    def errors(self, change):
        documents = copy.deepcopy(self.documents)
        change(documents)
        return '\n'.join(validate(documents)['errors'])

    def test_current_catalogue(self):
        self.assertEqual(validate(self.documents)['errors'], [])

    def test_duplicate_json_keys(self):
        with self.assertRaisesRegex(ValueError, 'duplicate JSON key'):
            unique_object([('id', 1), ('id', 2)])

    def test_duplicate_expansion_id(self):
        self.assertIn('duplicate cards ID', self.errors(
            lambda d: d['support_cards'].update(warrior_slash=d['content']['cards']['warrior_slash'])))

    def test_card_owner(self):
        self.assertIn('unknown owner', self.errors(
            lambda d: d['content']['cards']['warrior_slash'].update(owner='missing')))

    def test_unknown_encounter(self):
        self.assertIn('unknown enemy', self.errors(
            lambda d: d['dungeons']['1']['common'].append('missing')))

    def test_unknown_resource(self):
        self.assertIn('missing resource', self.errors(
            lambda d: d['card_art']['warrior_slash'].update(source='res://assets/missing.png')))

    def test_audio_reference(self):
        self.assertIn('unknown music', self.errors(
            lambda d: d['audio']['contexts']['combat'].update(music='missing')))

    def test_dynamic_enemy_visual(self):
        self.assertIn('missing dynamic asset', self.errors(
            lambda d: d['content']['enemies']['rat'].update(visual='missing')))

    def test_enemy_foreground_requires_both_actions(self):
        self.assertIn('missing foreground actions', self.errors(
            lambda d: d['enemy_visuals'][d['content']['enemies']['rat']['visual']]['foreground'].pop('defense')))

    def test_enemy_foreground_resource(self):
        self.assertIn('missing dynamic asset', self.errors(
            lambda d: d['enemy_visuals'][d['content']['enemies']['rat']['visual']]['foreground'].update(
                defense='res://assets/missing-defense.png')))


if __name__ == '__main__':
    unittest.main()
