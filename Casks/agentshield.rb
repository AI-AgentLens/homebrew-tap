cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1912"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1912/agentshield_0.2.1912_darwin_amd64.tar.gz"
      sha256 "4c510d6b5a225a10cb82d406c9070b95280d1d9a1e29deb32540b1f32b61c064"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1912/agentshield_0.2.1912_darwin_arm64.tar.gz"
      sha256 "a3a7a38380e7142de134a6b75ac38fe43818108450d36e701a7da4625f9320f1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1912/agentshield_0.2.1912_linux_amd64.tar.gz"
      sha256 "b7a8559aef700c124c9fbb5f3516cfcf762d4facd62df2d6e9ba8553f54784a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1912/agentshield_0.2.1912_linux_arm64.tar.gz"
      sha256 "abc31c76ef58b7848be4d02a7bbb8b4243413d38c49184d9e6d174313963ce64"
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
