cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1336"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1336/agentshield_0.2.1336_darwin_amd64.tar.gz"
      sha256 "db5d426dd2546a2b9b28701571dac0ad1b20cd6d29e896fedaeb8b4eb841b405"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1336/agentshield_0.2.1336_darwin_arm64.tar.gz"
      sha256 "2229caf43222e99d9a3e30135df71b439ce13c0a4bb7d08811760dae5a2639aa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1336/agentshield_0.2.1336_linux_amd64.tar.gz"
      sha256 "94881180eaf3cca7cd5d8d27ace1bcf7d096deb9a3997a39e85267d71c9be0a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1336/agentshield_0.2.1336_linux_arm64.tar.gz"
      sha256 "09cdbfe2dd85f560b17827dd54055ced1e14b5975a11018c379846d671124252"
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
