cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1904"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1904/agentshield_0.2.1904_darwin_amd64.tar.gz"
      sha256 "ffe7921ef41ec5b361b1db510f9a0604da245ff57d3959a428ba17ea67120e07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1904/agentshield_0.2.1904_darwin_arm64.tar.gz"
      sha256 "ad7617e373338adbc48224badabf895d24de21aebf48fcc5a500a5c97eaf2138"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1904/agentshield_0.2.1904_linux_amd64.tar.gz"
      sha256 "72cf5f8eef9c1d388ebac93bdb158013b61210415fb311fb5d3d6bbcca353990"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1904/agentshield_0.2.1904_linux_arm64.tar.gz"
      sha256 "e1c9ea6077e1ab03470212f3e246b6f536f8d2860c414369d8e86c3ef90ec423"
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
