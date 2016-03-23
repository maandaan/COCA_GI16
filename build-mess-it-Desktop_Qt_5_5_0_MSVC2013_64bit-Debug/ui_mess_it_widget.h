/********************************************************************************
** Form generated from reading UI file 'mess_it_widget.ui'
**
** Created by: Qt User Interface Compiler version 5.5.0
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MESS_IT_WIDGET_H
#define UI_MESS_IT_WIDGET_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_mess_it_widget
{
public:
    QVBoxLayout *verticalLayout_2;
    QGroupBox *groupBox;
    QVBoxLayout *verticalLayout;
    QPushButton *loadSceneButton;
    QPushButton *pushButton_2;
    QSpacerItem *verticalSpacer;

    void setupUi(QWidget *mess_it_widget)
    {
        if (mess_it_widget->objectName().isEmpty())
            mess_it_widget->setObjectName(QStringLiteral("mess_it_widget"));
        mess_it_widget->resize(213, 312);
        verticalLayout_2 = new QVBoxLayout(mess_it_widget);
        verticalLayout_2->setSpacing(6);
        verticalLayout_2->setContentsMargins(11, 11, 11, 11);
        verticalLayout_2->setObjectName(QStringLiteral("verticalLayout_2"));
        groupBox = new QGroupBox(mess_it_widget);
        groupBox->setObjectName(QStringLiteral("groupBox"));
        verticalLayout = new QVBoxLayout(groupBox);
        verticalLayout->setSpacing(6);
        verticalLayout->setContentsMargins(11, 11, 11, 11);
        verticalLayout->setObjectName(QStringLiteral("verticalLayout"));
        loadSceneButton = new QPushButton(groupBox);
        loadSceneButton->setObjectName(QStringLiteral("loadSceneButton"));

        verticalLayout->addWidget(loadSceneButton);

        pushButton_2 = new QPushButton(groupBox);
        pushButton_2->setObjectName(QStringLiteral("pushButton_2"));

        verticalLayout->addWidget(pushButton_2);

        verticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout->addItem(verticalSpacer);


        verticalLayout_2->addWidget(groupBox);


        retranslateUi(mess_it_widget);

        QMetaObject::connectSlotsByName(mess_it_widget);
    } // setupUi

    void retranslateUi(QWidget *mess_it_widget)
    {
        mess_it_widget->setWindowTitle(QApplication::translate("mess_it_widget", "mess_it_widget", 0));
        groupBox->setTitle(QApplication::translate("mess_it_widget", "GroupBox", 0));
        loadSceneButton->setText(QApplication::translate("mess_it_widget", "Load Scene", 0));
        pushButton_2->setText(QApplication::translate("mess_it_widget", "PushButton", 0));
    } // retranslateUi

};

namespace Ui {
    class mess_it_widget: public Ui_mess_it_widget {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MESS_IT_WIDGET_H
