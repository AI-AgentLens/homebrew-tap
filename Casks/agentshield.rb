cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.650"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.650/agentshield_0.2.650_darwin_amd64.tar.gz"
      sha256 "f26e69c341f204a24f42d620bff1b061d5c4c366945c631ee089f6f2af91ebf5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.650/agentshield_0.2.650_darwin_arm64.tar.gz"
      sha256 "86eb4c00386ddd597d7443faaa1580b3c1da2a85cc98da22de796c3eeab2450b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.650/agentshield_0.2.650_linux_amd64.tar.gz"
      sha256 "5d5ae8cde673a080bb45b161e9f148f28f94fb8c55295e6cc0c25347c9b599d9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.650/agentshield_0.2.650_linux_arm64.tar.gz"
      sha256 "0cbdbfbf31291d2fb8a3f444200c85ae6de49c99255643bd15f02d400afd292e"
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
