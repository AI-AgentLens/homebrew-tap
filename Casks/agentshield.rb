cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1588"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1588/agentshield_0.2.1588_darwin_amd64.tar.gz"
      sha256 "e724fa3613640f72c6a76566b3d335966eb4a057d5c638b080ac8b8ad0d9bfcf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1588/agentshield_0.2.1588_darwin_arm64.tar.gz"
      sha256 "5eda09ac04819d74a39ad5ee7ce90acafbcbc54a294d25513272db48f51fd7bb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1588/agentshield_0.2.1588_linux_amd64.tar.gz"
      sha256 "e62ec3f45b75228ee5b4540913c0aea4427352bbbcf50c5e9e1d785c2dd6d8ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1588/agentshield_0.2.1588_linux_arm64.tar.gz"
      sha256 "fbfc9da89cc8d20b02d3f375d23abf8e419639e3890fe851fa22317ba448aaf4"
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
