cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1750"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1750/agentshield_0.2.1750_darwin_amd64.tar.gz"
      sha256 "f4bda023d62973ed921ffe59b787503a9cdc959a89895748cf069a1c65e367db"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1750/agentshield_0.2.1750_darwin_arm64.tar.gz"
      sha256 "0b167aafe2cd8c5b6ec65a4ce9862affbf79cc4f66d43b586d21636334ab004f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1750/agentshield_0.2.1750_linux_amd64.tar.gz"
      sha256 "46feaf04d667906fda9bf15b46db31352759abcf7d159fc888e42f98f8614280"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1750/agentshield_0.2.1750_linux_arm64.tar.gz"
      sha256 "9bc99b9dfca311d292aa952a807419048d6c1eb3692345ced41fc31e0aa0fd48"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
