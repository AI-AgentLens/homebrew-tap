cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2385"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2385/agentshield_0.2.2385_darwin_amd64.tar.gz"
      sha256 "1dd4f5ec454939a2fe9e84a5d8ee441e99526ee56b6c30ac7249bc62c759262c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2385/agentshield_0.2.2385_darwin_arm64.tar.gz"
      sha256 "87c778a8661b288b47a3962dada8c5c3fd574b2277257c972b0c67b5cfc16fb4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2385/agentshield_0.2.2385_linux_amd64.tar.gz"
      sha256 "0b18c87dec6f295e1c7ee4277740bd1d83b15cbecb276dce423230973ee6b7e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2385/agentshield_0.2.2385_linux_arm64.tar.gz"
      sha256 "a2900747bc388b27b505b503c92d1882d35d83f3c4c771d0000dd10d9dfe59bc"
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
