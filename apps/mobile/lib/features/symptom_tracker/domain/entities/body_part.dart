/// 身体部位枚举
enum BodyPart {
  // 头部区域
  head('头部', BodyRegion.head),
  forehead('前额', BodyRegion.head),
  temple('太阳穴', BodyRegion.head),
  eye('眼睛', BodyRegion.head),
  ear('耳朵', BodyRegion.head),
  nose('鼻子', BodyRegion.head),
  mouth('嘴巴', BodyRegion.head),
  throat('喉咙', BodyRegion.head),
  neck('颈部', BodyRegion.head),

  // 胸部区域
  chest('胸部', BodyRegion.chest),
  heart('心脏区域', BodyRegion.chest),
  lung('肺部', BodyRegion.chest),
  breast('乳房', BodyRegion.chest),

  // 腹部区域
  abdomen('腹部', BodyRegion.abdomen),
  stomach('胃部', BodyRegion.abdomen),
  liver('肝区', BodyRegion.abdomen),
  intestine('肠道', BodyRegion.abdomen),
  lowerAbdomen('下腹部', BodyRegion.abdomen),

  // 背部区域
  upperBack('上背部', BodyRegion.back),
  middleBack('中背部', BodyRegion.back),
  lowerBack('腰部', BodyRegion.back),
  spine('脊柱', BodyRegion.back),

  // 四肢
  shoulder('肩膀', BodyRegion.limbs),
  upperArm('上臂', BodyRegion.limbs),
  elbow('肘部', BodyRegion.limbs),
  forearm('前臂', BodyRegion.limbs),
  wrist('手腕', BodyRegion.limbs),
  hand('手', BodyRegion.limbs),
  finger('手指', BodyRegion.limbs),
  hip('髋部', BodyRegion.limbs),
  thigh('大腿', BodyRegion.limbs),
  knee('膝盖', BodyRegion.limbs),
  calf('小腿', BodyRegion.limbs),
  ankle('脚踝', BodyRegion.limbs),
  foot('脚', BodyRegion.limbs),
  toe('脚趾', BodyRegion.limbs),

  // 皮肤/全身
  skin('皮肤', BodyRegion.whole),
  wholeBody('全身', BodyRegion.whole),
  joint('关节', BodyRegion.whole),
  muscle('肌肉', BodyRegion.whole);

  final String displayName;
  final BodyRegion region;

  const BodyPart(this.displayName, this.region);

  static List<BodyPart> getByRegion(BodyRegion region) {
    return BodyPart.values.where((part) => part.region == region).toList();
  }
}

/// 身体区域分组
enum BodyRegion {
  head('头颈部'),
  chest('胸部'),
  abdomen('腹部'),
  back('背部'),
  limbs('四肢'),
  whole('全身/其他');

  final String displayName;

  const BodyRegion(this.displayName);
}
