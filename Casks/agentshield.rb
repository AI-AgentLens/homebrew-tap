cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.997"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.997/agentshield_0.2.997_darwin_amd64.tar.gz"
      sha256 "9fc247f872823abe9cb7cafafd65b23719d3f9302b8bb9bbb97d75406d803616"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.997/agentshield_0.2.997_darwin_arm64.tar.gz"
      sha256 "0d7ba5647ca2c2b4e3a26b5aee8d90e46fda9770781f1c31b6d3d3474c32b1ab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.997/agentshield_0.2.997_linux_amd64.tar.gz"
      sha256 "c085f3bd14d37b8b3e46bff834bfbee749e43c7290bf149c07a4ae9a7fcf1b8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.997/agentshield_0.2.997_linux_arm64.tar.gz"
      sha256 "44aaefb218400114908db3831872cbecc91bd73f493f799d4d4930d7b3271cff"
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
