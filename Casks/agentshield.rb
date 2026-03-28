cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.163"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.163/agentshield_0.2.163_darwin_amd64.tar.gz"
      sha256 "f0ec665f37b93ba9edb0661ac9f1d7f5838d2484175440a1d6c4c2d3f6a842a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.163/agentshield_0.2.163_darwin_arm64.tar.gz"
      sha256 "a875267f8a41d577da52a5b09d480c22229bed92a3d86904fe32c32654873dd7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.163/agentshield_0.2.163_linux_amd64.tar.gz"
      sha256 "c896dd4802716d7b66dd14dcca58b16f82cf170a3ed115ef569a223a4b5ecf82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.163/agentshield_0.2.163_linux_arm64.tar.gz"
      sha256 "52576e50dc27b7cb61c49f06dbc777c9ec58ad0fb08f5090b22907ea5f6e1ab4"
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
