cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.231"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.231/agentshield_0.2.231_darwin_amd64.tar.gz"
      sha256 "e236433d7718158d4627a3a1d83d878512fa57e2bc8f631347e245bc9d73a8f9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.231/agentshield_0.2.231_darwin_arm64.tar.gz"
      sha256 "a582d660071ac1ed53e67f46cdaea871ee03a32a33f04b4470760b217fc6b0c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.231/agentshield_0.2.231_linux_amd64.tar.gz"
      sha256 "ddf1e60759feb9673b5686447f49d457ed80149879f36039638d26a88ed8e4b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.231/agentshield_0.2.231_linux_arm64.tar.gz"
      sha256 "4c6edcf9c1dd373d6bac001f5b15d0b0eac2223b98bd23dbcfa465b62c203561"
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
