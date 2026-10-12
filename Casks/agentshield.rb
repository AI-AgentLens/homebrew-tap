cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2418"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2418/agentshield_0.2.2418_darwin_amd64.tar.gz"
      sha256 "45eed02310e732b15f2be1ea6cdfbb6214b7254e288df44b037ac65617b8d033"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2418/agentshield_0.2.2418_darwin_arm64.tar.gz"
      sha256 "4dc788933484dd15b6d816eb9b816d875f0bc22bf2306ca17e52d7d9a3c9e39b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2418/agentshield_0.2.2418_linux_amd64.tar.gz"
      sha256 "fa39f762e5bb6b5e2bc2b3bef175cf6f3e60766dd220a21ab740f811f7634a31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2418/agentshield_0.2.2418_linux_arm64.tar.gz"
      sha256 "457ebf00f8d03a0fc6a51014ecf301c344a8809c18666be131eb84bc4204155b"
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
