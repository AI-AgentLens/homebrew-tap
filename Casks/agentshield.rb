cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2254"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2254/agentshield_0.2.2254_darwin_amd64.tar.gz"
      sha256 "ed6c806a95173fb391f5325a73e22067abf323f536118f2f71b85a855c8bd2e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2254/agentshield_0.2.2254_darwin_arm64.tar.gz"
      sha256 "7ef437ca797e2abe9959da3bb59bfa233377ac339989754e8c1e6e7cf0009115"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2254/agentshield_0.2.2254_linux_amd64.tar.gz"
      sha256 "d8a8c554782206213d5b97ce52fb789bd96cbcbf8cdaa01881af88b6433a2e44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2254/agentshield_0.2.2254_linux_arm64.tar.gz"
      sha256 "cf88135324c7de25038f25f26a06d9e468d7ee1cd23cbf06afb913f4ed0d007a"
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
