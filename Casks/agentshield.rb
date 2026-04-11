cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.545"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.545/agentshield_0.2.545_darwin_amd64.tar.gz"
      sha256 "ac2e20b99b0ded23e6934a9e9cb7b2859c43f39459e3a3a8983322dc3c480d9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.545/agentshield_0.2.545_darwin_arm64.tar.gz"
      sha256 "098c3787798364424f0bb6f66db89df0c2b169e0a5a35bba53b16998e10509d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.545/agentshield_0.2.545_linux_amd64.tar.gz"
      sha256 "f128a015894a2261755323baa364f557247474bb6682c23f46208cef1ffc42e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.545/agentshield_0.2.545_linux_arm64.tar.gz"
      sha256 "d09cc63278e19fc465f060768868f2d4f621d18cfb07496188e5dfd34240e11c"
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
