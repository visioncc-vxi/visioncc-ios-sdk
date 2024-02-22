//
//  ChatMachineCell.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/26.
//

import UIKit
import SnapKit
@_implementationOnly import VisionCCiOSSDKEngine

/// 机器人列
class ChatMachineBaseCell: BaseChatCell {
    
    /// 点击回调
    public var clickCellBlock:((_ _selectedIndex:Int, _ _item:MessageGroupItems)->Void)?
    
    private lazy var listView : ChatMachineListView = ChatMachineListView()
    
    //MARK: - override
    override func layoutUI() {
        isNeedBubbleBackground = false
        super.layoutUI()
        
        contentView.addSubview(listView)
        listView.clickCellBlock = {[weak self](index, _item) in
            guard let self = self else { return }
            self.clickCellBlock?(index, _item)
        }
    }
    
    //MARK: 更新数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        //机器人图像
        VXIUIConfig.shareInstance.cellMachineImage(ImageView: self.messageAvatarsImageView,
                                                   andSize: VXIUIConfig.shareInstance.cellUserImageSize())
        
        messagebubbleBackImageView?.isHidden = true
        messageUserNameLabel.isHidden = true
        
        var _arritems = [MessageGroupItems]()
        if let _items = m.messageBody?.question_group?.first?.items {
            _arritems = _items.filter({ $0.title != nil && $0.title?.isEmpty == false })
        }
        self.listView.updateData(tipStr: m.messageBody?.content ?? "请选择", listArr: _arritems)
        
        listView.snp.remakeConstraints({[weak self] (make) in
            guard let self = self else { return }
            make.left.equalTo(messageAvatarsImageView.snp.right).offset(VXIUIConfig.shareInstance.cellLeftOrRightContentMargin())
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.top.equalTo(messageAvatarsImageView.snp.top)
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
        })
        
        layoutIfNeeded()
    }
    
}


//MARK: - ChatMachineListView
class ChatMachineListView: UIView {
    /// 点击回调
    var clickCellBlock:((_ _selectedIndex:Int, _ _item:MessageGroupItems)->Void)?
    
    //MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        addSubview(self.topBgView)
        topBgView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.top.right.equalToSuperview()
        }
        
        addSubview(tv)
        tv.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.top.equalTo(self.topBgView.snp.bottom).offset(8)
            make.height.equalTo(100)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func updateData(tipStr:String, listArr:[MessageGroupItems]){
        self.topTipLabel.text = tipStr
        let (_h,_size) = tipStr.yl_getLabelHeight(Font: self.topTipLabel.font!,
                                                  andWidth: 220.5)
        let _top_w:CGFloat = min(_size.width + 5,VXIUIConfig.shareInstance.cellMaxWidth())
        let _top_h:CGFloat = max(_h, 20)
        self.topTipLabel.snp.remakeConstraints { make in
            make.height.equalTo(_top_h)
            make.left.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(_top_w)
        }
        
        topBgView.snp.remakeConstraints { make in
            make.height.equalTo(_top_h + 20)
            make.width.equalTo(_top_w + 20)
            make.left.top.equalToSuperview()
        }
        
        dataArr = listArr
        tv.snp.remakeConstraints {[weak self] make in
            guard let self = self else { return }
            make.top.equalTo(self.topBgView.snp.bottom).offset(8)
            make.height.equalTo(VXIUIConfig.shareInstance.cellTableViewDefaultHeight() * CGFloat(dataArr.count))
            make.left.right.bottom.equalToSuperview()
        }
        
        tv.reloadData()
        layoutIfNeeded()
    }
    
    //MARK: - lazy load
    private lazy var topBgView:UIView = {[unowned self] in
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        //bgView.layer.masksToBounds = true //masksToBounds会造成离屏渲染
        bgView.addSubview(self.topTipLabel)
        
        self.topTipLabel.snp.makeConstraints { make in
            make.left.top.equalTo(10)
            make.bottom.right.equalTo(-10)
            make.height.equalTo(20)
        }
        return bgView
    }()
    
    
    private lazy var topTipLabel : YYLabel = {
        let _lab = TGSUIModel.createLable(rect: .zero,
                                          text: "欢迎进入客户咨询中心",
                                          textColor: VXIUIConfig.shareInstance.cellMessageColor(),
                                          font: .systemFont(ofSize: VXIUIConfig.shareInstance.cellMessageQuestionFont(), weight: .regular),
                                          andTextAlign: .left)
        _lab.numberOfLines = 0
        return _lab
    }()
    
    private lazy var dataArr:[MessageGroupItems] = []
    
    private lazy var cellId = "ChatMachineListViewCell"
    
    fileprivate lazy var tv : UITableView = {[unowned self] in
        let tv = TGSUIModel.createTableView()
        
        tv.register(ChatMachineListViewCell.self, forCellReuseIdentifier: cellId)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor.white
        tv.bounces = false
        tv.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        //tv.layer.masksToBounds = true //masksToBounds会造成离屏渲染
        return tv
    }()
}


//MARK: - tableview 代理
extension ChatMachineListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickCellBlock?(indexPath.row, dataArr[indexPath.row])
        print("ChatMachineCell  clickCellBlock?( \(indexPath.row), \(dataArr[indexPath.row]) )")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMachineListViewCell
        if dataArr.count == 0 {
            return cell
        }
        
        cell.updateData(item: dataArr[indexPath.row], isHiddenLine: indexPath.row == (dataArr.count - 1))
        return cell
    }
}


//MARK: - 列表cell
/// 列表cell
class ChatMachineListViewCell: UITableViewCell {
    
    ///左侧标题
    private lazy var showContentLabel : YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      text: nil,
                                      textColor: TGSUIModel.createColorHexString("#424242"),
                                      font: UIFont.systemFont(ofSize: VXIUIConfig.shareInstance.cellMessageQuestionFont(), weight: UIFont.Weight.semibold),
                                      andTextAlign: .left)
    }()
    
    ///分割线
    private lazy var lineView :YYLabel = {
        return TGSUIModel.createLable(rect: .zero,
                                      backgroundColor: TGSUIModel.createColorHexString("#EEEEEE"))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(item:MessageGroupItems?, isHiddenLine:Bool){
        showContentLabel.text = item?.title
        lineView.isHidden = isHiddenLine
    }
}


// MARK: - UI
extension ChatMachineListViewCell{
    private func configUI(){
        self.selectionStyle = .none
        self.backgroundColor = TGSUIModel.createColorHexString("#FFFFFF")
        
        contentView.addSubview(showContentLabel)
        showContentLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.bottom.right.equalTo(-10)
        }
        
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
