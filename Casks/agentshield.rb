cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1361"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1361/agentshield_0.2.1361_darwin_amd64.tar.gz"
      sha256 "b0940f64ce5381043090d65dff37e6d23bc582f8bd21ec2c4e3386abc71c738f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1361/agentshield_0.2.1361_darwin_arm64.tar.gz"
      sha256 "e0993938e888f78c4a5d9d8aef49f6e90424ae82d1a0830e77d57685e917ee20"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1361/agentshield_0.2.1361_linux_amd64.tar.gz"
      sha256 "0e201defaca922bc21a41d4b5d05d9fdd5c40326a0d3b2d1e82fd9759c849aeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1361/agentshield_0.2.1361_linux_arm64.tar.gz"
      sha256 "1b24da17791e3fde74617525e0d9f7a89da93bf5923f1ff44bee40bcef3904b3"
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
