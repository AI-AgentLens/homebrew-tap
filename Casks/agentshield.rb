cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1413"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1413/agentshield_0.2.1413_darwin_amd64.tar.gz"
      sha256 "3d6e4c104b5dfe03eb7566757f0d271ecb076773a32176da48044c5c7a17fbb2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1413/agentshield_0.2.1413_darwin_arm64.tar.gz"
      sha256 "b0d51bb8a7fe5560ebf6083d92896fc1284262b04c4ba9a35c21a1862ffbd00b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1413/agentshield_0.2.1413_linux_amd64.tar.gz"
      sha256 "dedfde08ad25012dba1b7d75188f5ba2f4924445461cb5879523db498aabd4f5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1413/agentshield_0.2.1413_linux_arm64.tar.gz"
      sha256 "0713d26c321ff46edf39bf347d0b5edb8d7a664c55c4d9136fc87731332965dd"
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
