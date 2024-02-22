//
//  ChatMachineTabCell.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/27.
//

import UIKit
import SnapKit
import JXSegmentedView
import RealmSwift

/// 热点问题列表(分栏菜单)
class ChatMachineTabCell: BaseChatCell {
    
    /// 点击cell回调
    public var clickCellBlock:((_ selectedTabIndex:Int, _ selectedTabStr:String,  _ selectedCellIndex:Int, _ selectedCellStr:String,_ _item:MessageGroupItems?)->Void)?
    
    //换一批
    public var clickChangeNewBlock:(()->())?
    
    
    //MARK: - overrddie
    override func layoutUI() {
        super.layoutUI()
        contentView.addSubview(self.bgView)
    }
    
    //MARK: - 更新数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        VXIUIConfig.shareInstance.cellMachineImage(ImageView: self.messageAvatarsImageView,
                                                   andSize: VXIUIConfig.shareInstance.cellUserImageSize())
        
        isNeedBubbleBackground = false
        messagebubbleBackImageView?.isHidden = true
        messageUserNameLabel.isHidden = true
        
        //加载数据
        var titleArr = [String]()
        self.dataArr.removeAll()
        if let _items = m.messageBody?.question_group {
            self.dataArr = _items
            for _item in _items where _item.name != nil && _item.name?.isEmpty == false {
                titleArr.append(_item.name!)
            }
        }
        self.selectedTabIndex = 0
        self.segmentedView.updateTitleArr(titleArr: titleArr)
        
        //更新约束
        bgView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(messageAvatarsImageView.snp.right).offset(8)
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.top.equalTo(messageAvatarsImageView)
            make.height.equalTo(CGFloat(34) + VXIUIConfig.shareInstance.cellTableViewDefaultHeight() * CGFloat(self.dataArr.count))
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
        }
        
        layoutIfNeeded()
    }
    
    
    //MARK: - lazy load
    private lazy var cellId = "ChatMachineListViewCell"
    
    private lazy var bgView:UIView = {[unowned self] in
        let bgView = UIView()
        bgView.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        bgView.addSubview(segmentedView)
        segmentedView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
        }
        bgView.addSubview(tv)
        tv.snp.remakeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.height.equalTo(VXIUIConfig.shareInstance.cellTableViewDefaultHeight() * CGFloat(self.dataArr.count))
        })
        
        bgView.addSubview(self.changeView)
        changeView.snp.makeConstraints { make in
            make.top.equalTo(tv.snp.bottom)
            make.height.equalTo(40)
            make.left.right.bottom.equalToSuperview()
        }
        return bgView
    }()
    
    private lazy var changeView:UIView = {[unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor.white
        
        let btn = TGSVerBtn()
        btn.setTitle("换一批", for: UIControl.State.normal)
        btn.setTitleColor(TGSUIModel.createColorHexInt(0x9E9E9E), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "tool_change.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: UIControl.State.normal)
        btn.imagePosition(style: TGSVerBtn.RGButtonImagePosition.left, spacing: 6.5)
        btn.rx.tap.subscribe {[weak self] event in
            self?.clickChangeNewBlock?()
        }.disposed(by: rx.disposeBag)
        v.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(100)
            make.right.equalTo(-10)
        }
        return v
    }()
    
    private lazy var segmentedView : ChatMachineTabSegmentedView = {
        let view =  ChatMachineTabSegmentedView()
        view.backgroundColor = UIColor.white
        view.clickBlock = {[weak self](selectedIndex:Int, title:String)in
            guard let self = self else { return }
            self.selectedTabIndex = selectedIndex
        }
        return view
    }()
    
    private lazy var dataArr = [MessageQuestions]()
    private lazy var selectedTabIndex:Int = 0 {
        didSet{
            if self.dataArr.count > self.selectedTabIndex {
                self.tv.reloadData()
            }
        }
    }
    
    private lazy var selectedTabStr:String = ""
    
    private lazy var tv : UITableView = {[unowned self] in
        let tv = TGSUIModel.createTableView(style: UITableView.Style.plain, separatorStyle: UITableViewCell.SeparatorStyle.none)
        tv.register(ChatMachineListViewCell.self, forCellReuseIdentifier: cellId)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor.white
        tv.bounces = false
        tv.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        return tv
    }()
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension ChatMachineTabCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count > self.selectedTabIndex ? self.dataArr[self.selectedTabIndex].items.count : 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataArr.count > self.selectedTabIndex {
            let items = self.dataArr[self.selectedTabIndex].items
            if items.count > indexPath.row {
                clickCellBlock?(self.selectedTabIndex, selectedTabStr, indexPath.row, items[indexPath.row].title ?? "",items[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMachineListViewCell
        
        if self.dataArr.count > self.selectedTabIndex {
            let items = self.dataArr[self.selectedTabIndex].items
            if items.count > indexPath.row {
                cell.updateData(item: items[indexPath.row], isHiddenLine: false)
            }
        }
        
        return cell
    }
}


//MARK: - 分段点击视图
/// 分段点击视图
class ChatMachineTabSegmentedView: UIView {
    
    /// 标题数据源
    private lazy var titleDataSource = JXSegmentedTitleDataSource()
    private lazy var segmentedView = JXSegmentedView()
    
    /// 点击回调
    var clickBlock:((_ selectedIndex:Int, _ selectedTitle:String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新标题
    func updateTitleArr(titleArr:[String]){
        self.titleDataSource.titles = titleArr
        self.segmentedView.dataSource = self.titleDataSource
    }
}

extension ChatMachineTabSegmentedView{
    
    private func setUI(){
        segmentedView = JXSegmentedView()
        segmentedView.delegate = self
        addSubview(segmentedView)
        segmentedView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.edges.equalTo(self)
        }
        
        //segmentedDataSource一定要通过属性强持有，不然会被释放掉
        titleDataSource = JXSegmentedTitleDataSource()
        
        //配置数据源相关配置属性
        titleDataSource.isTitleColorGradientEnabled = false
        
        //关联dataSource
        segmentedView.dataSource = self.titleDataSource
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: VXIUIConfig.shareInstance.cellMessageQuestionFont(), weight: UIFont.Weight.regular)
        titleDataSource.titleSelectedColor = VXIUIConfig.shareInstance.cellHighlightColor()
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: VXIUIConfig.shareInstance.cellMessageQuestionFont(), weight: UIFont.Weight.regular)
        titleDataSource.titleNormalColor = VXIUIConfig.shareInstance.cellnornalColor()
        
        ///初始化指示器indicator
        let indicator = JXSegmentedIndicatorLineView()
        indicator.isScrollEnabled = false///不允许滚动
        indicator.indicatorColor = VXIUIConfig.shareInstance.cellHighlightColor()
        segmentedView.indicators = [indicator]
    }
}


//MARK: - JXSegmentedViewDelegate
extension ChatMachineTabSegmentedView: JXSegmentedViewDelegate{
    
    // 点击选中的情况才会调用该方法
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        clickBlock?(index, self.titleDataSource.titles[index])
    }
    
}

