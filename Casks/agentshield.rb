cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1739"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1739/agentshield_0.2.1739_darwin_amd64.tar.gz"
      sha256 "7b71b7726926d049f21fd047a71129f960bb12df042577f6db524934f119732c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1739/agentshield_0.2.1739_darwin_arm64.tar.gz"
      sha256 "3522df83817f01030c26fb884c525bda3c327cfb7c8e85e402ab4e6a4639452d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1739/agentshield_0.2.1739_linux_amd64.tar.gz"
      sha256 "7a817c041a877009a2b04834fbabd5e10abb052cfbc40441042047b2379329f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1739/agentshield_0.2.1739_linux_arm64.tar.gz"
      sha256 "be982aa34cffead34a69b40ef168c2e2d8bf712d33e1f7c658e346b9fe16be6a"
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
